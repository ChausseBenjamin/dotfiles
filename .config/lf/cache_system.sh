#!/bin/bash

# Smart PNG Cache System for LF Previews
# 720p PNGs for images, 1080p for text-based content (PDFs)

set -euo pipefail

# Configuration
CACHE_DIR="${LF_CACHE_DIR:-$HOME/.cache/lf-previews}"
IMAGE_CACHE_WIDTH=1280    # 720p width
IMAGE_CACHE_HEIGHT=720    # 720p height
TEXT_CACHE_WIDTH=1920     # 1080p width for PDFs/text
TEXT_CACHE_HEIGHT=1080    # 1080p height for PDFs/text
MAX_THREADS=8

# Cache size management
MAX_CACHE_SIZE_MB=1024    # 1GB maximum cache size
TARGET_CACHE_SIZE_MB=512  # Target size after cleanup (50% of max)

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"/{images,metadata,locks} 2>/dev/null

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"/{images,metadata,locks} 2>/dev/null

# Check if we should ignore this file for caching
should_ignore_file() {
    local file="$1"

    # Ignore files in the cache directory itself
    if [[ "$file" == "$CACHE_DIR"* ]]; then
        return 0  # true - ignore
    fi

    return 1  # false - don't ignore
}

# Check if file should be cached based on format and size
should_cache_file() {
    local file="$1"
    local mime_type="$2"

    # Don't cache if we should ignore this file
    if should_ignore_file "$file"; then
        return 1
    fi

    case "$mime_type" in
        image/png)
            # Check PNG dimensions - don't cache if already smaller than 720p
            local dimensions
            dimensions=$(magick identify -format "%w %h" "$file" 2>/dev/null || echo "0 0")
            read -r width height <<< "$dimensions"

            if [[ $width -le $IMAGE_CACHE_WIDTH && $height -le $IMAGE_CACHE_HEIGHT ]]; then
                return 1  # Don't cache - already small enough
            fi
            return 0  # Cache it
            ;;
        image/jpeg | image/jpg | image/webp | image/heic | image/gif | image/*)
            return 0  # Cache these formats
            ;;
        */pdf | image/vnd.djvu)
            return 0  # Cache text-based content at high resolution
            ;;
        font/* | application/vnd.ms-opentype)
            return 0  # Cache fonts
            ;;
        video/*)
            return 0  # Cache video thumbnails
            ;;
        *)
            return 1  # Don't cache other formats
            ;;
    esac
}

# Check if cached version exists and is valid
cache_hit() {
    local cache_key="$1"
    local cache_file="$CACHE_DIR/images/${cache_key}.png"
    local meta_file="$CACHE_DIR/metadata/${cache_key}.meta"

    if [[ -r "$cache_file" && -r "$meta_file" ]]; then
        # Update access time for LRU cleanup
        touch "$cache_file" "$meta_file" 2>/dev/null
        return 0
    fi
    return 1
}

# Get path to cached file
get_cache_path() {
    local cache_key="$1"
    echo "$CACHE_DIR/images/${cache_key}.png"
}

# Generate cached PNG for a file
generate_cache() {
    local file="$1"
    local mime_type="$2"
    local is_text_content="$3"  # 1 for PDFs/text, 0 for images

    # Determine resolution based on content type
    local target_width target_height
    if [[ "$is_text_content" == "1" ]]; then
        target_width=$TEXT_CACHE_WIDTH
        target_height=$TEXT_CACHE_HEIGHT
    else
        target_width=$IMAGE_CACHE_WIDTH
        target_height=$IMAGE_CACHE_HEIGHT
    fi

    local cache_key
    local file_stat cache_input
    file_stat=$(stat -c "%Y-%s-%n" "$file" 2>/dev/null || echo "missing")
    cache_input="${file_stat}-${target_width}x${target_height}"
    cache_key=$(echo "$cache_input" | sha256sum | cut -d' ' -f1)

    local cache_file="$CACHE_DIR/images/${cache_key}.png"
    local meta_file="$CACHE_DIR/metadata/${cache_key}.meta"
    local temp_file="/tmp/lf_cache_${cache_key}.png"

    # Generate the cached image
    local success=0

    case "$mime_type" in
        image/png)
            # PNG: High-quality resize (we already checked it's bigger than target)
            magick convert "$file" \
                -filter Mitchell \
                -resize "${target_width}x${target_height}>" \
                -quality 100 \
                "$temp_file" 2>/dev/null && success=1
            ;;
        image/jpeg | image/jpg)
            # JPEG: Convert to PNG with high quality
            magick convert "$file" \
                -filter Mitchell \
                -resize "${target_width}x${target_height}>" \
                -quality 100 \
                "$temp_file" 2>/dev/null && success=1
            ;;
        image/webp)
            # WebP: Decode then convert to PNG
            if command -v dwebp >/dev/null 2>&1; then
                dwebp "$file" -png -o - 2>/dev/null | \
                magick convert - \
                    -filter Mitchell \
                    -resize "${target_width}x${target_height}>" \
                    -quality 100 \
                    "$temp_file" 2>/dev/null && success=1
            else
                magick convert "$file" \
                    -filter Mitchell \
                    -resize "${target_width}x${target_height}>" \
                    -quality 100 \
                    "$temp_file" 2>/dev/null && success=1
            fi
            ;;
        image/heic)
            # HEIC: Convert to PNG
            magick convert "$file" \
                -filter Mitchell \
                -resize "${target_width}x${target_height}>" \
                -quality 100 \
                "$temp_file" 2>/dev/null && success=1
            ;;
        image/gif)
            # GIF: First frame to PNG
            magick convert "${file}[0]" \
                -filter Mitchell \
                -resize "${target_width}x${target_height}>" \
                -quality 100 \
                "$temp_file" 2>/dev/null && success=1
            ;;
        image/vnd.djvu)
            # DjVu: High-resolution extraction
            djvused "$file" -e 'select 1; save-page-with /dev/stdout' 2>/dev/null | \
            magick djvu:- \
                -filter Mitchell \
                -resize "${target_width}x${target_height}>" \
                -quality 100 \
                "$temp_file" 2>/dev/null && success=1
            ;;
        */pdf)
            # PDF: High-DPI rendering for maximum text clarity
            if command -v pdftocairo >/dev/null 2>&1; then
                # First try high-DPI rendering without size constraints
                pdftocairo -singlefile -r 300 -png "$file" "${temp_file%.*}" 2>/dev/null
                if [[ -f "${temp_file%.*}-1.png" ]]; then
                    mv "${temp_file%.*}-1.png" "$temp_file"
                elif [[ -f "${temp_file%.*}.png" && "${temp_file%.*}.png" != "$temp_file" ]]; then
                    mv "${temp_file%.*}.png" "$temp_file"
                elif [[ -f "${temp_file%.*}.png" ]]; then
                    # File already has correct name, but might need resizing
                    true
                fi

                # Now resize to target if needed and file exists
                if [[ -f "$temp_file" ]]; then
                    # Resize while preserving aspect ratio and quality
                    magick convert "$temp_file" \
                        -filter Mitchell \
                        -resize "${target_width}x${target_height}>" \
                        -quality 100 \
                        "${temp_file}.tmp" 2>/dev/null && \
                    mv "${temp_file}.tmp" "$temp_file" && success=1
                fi
            else
                magick convert -density 300 "${file}[0]" \
                    -filter Mitchell \
                    -resize "${target_width}x${target_height}>" \
                    -background white -flatten \
                    -quality 100 \
                    "$temp_file" 2>/dev/null && success=1
            fi
            ;;
        video/*)
            # Video: Thumbnail to PNG
            if command -v ffmpegthumbnailer >/dev/null 2>&1; then
                ffmpegthumbnailer -i "$file" -s "$target_width" -c png -f -q 10 -o "$temp_file" 2>/dev/null && success=1
            else
                ffmpeg -i "$file" -ss 00:00:01 -vframes 1 -f image2 -vf "scale=${target_width}:${target_height}:force_original_aspect_ratio=decrease" "$temp_file" 2>/dev/null && success=1
            fi
            ;;
        font/* | application/vnd.ms-opentype)
            # Font: Preview generation
            local font_name
            font_name=$(fc-query --format "%{family}\n" "$file" 2>/dev/null | head -n 1)
            local preview_text="${font_name:-Font Preview}
ABCDEFGHIJKLMNOPQRSTUBWXYZ
abcdefghijklmnopqrstuvwxyz
1234567890
!@#\$%(){}[]-+=_\`~"
            magick convert -size "${target_width}x${target_height}" xc:'#ffffff' \
                -gravity center -pointsize 76 \
                -font "$file" \
                -fill '#000000' \
                -annotate +0+0 "$preview_text" \
                "$temp_file" 2>/dev/null && success=1
            ;;
        *)
            success=0
            ;;
    esac

    # Store in cache if successful
    if [[ $success -eq 1 && -f "$temp_file" ]]; then
        mv "$temp_file" "$cache_file"

        # Store metadata
        cat > "$meta_file" << EOF
original_file=$file
mime_type=$mime_type
cached_at=$(date +%s)
resolution=${target_width}x${target_height}
cache_key=$cache_key
EOF
        echo "$cache_key"
        return 0
    fi

    rm -f "$temp_file"
    return 1
}

# Check if file has cached version (without generating) - fixed version
check_file_cached() {
    local file="$1"
    local mime_type="$2"
    
    # Skip cache directory files  
    [[ "${file#$CACHE_DIR}" != "$file" ]] && return 1
    
    # Quick mime type validation
    case "$mime_type" in
        image/jpeg|image/jpg|image/webp|image/heic|image/gif|image/png|image/*|*/pdf|image/vnd.djvu|video/*|font/*|application/vnd.ms-opentype)
            ;;
        *)
            return 1
            ;;
    esac
    
    # Determine resolution based on content type
    local target_width target_height
    case "$mime_type" in
        */pdf | image/vnd.djvu | font/* | application/vnd.ms-opentype)
            target_width=$TEXT_CACHE_WIDTH
            target_height=$TEXT_CACHE_HEIGHT
            ;;
        *)
            target_width=$IMAGE_CACHE_WIDTH
            target_height=$IMAGE_CACHE_HEIGHT
            ;;
    esac
    
    # Generate cache key directly
    local file_stat cache_input cache_key
    file_stat=$(stat -c "%Y-%s-%n" "$file" 2>/dev/null || echo "missing")
    cache_input="${file_stat}-${target_width}x${target_height}"
    cache_key=$(echo "$cache_input" | sha256sum | cut -d' ' -f1)
    
    # Check cache files
    local cache_file="$CACHE_DIR/images/${cache_key}.png"
    local meta_file="$CACHE_DIR/metadata/${cache_key}.meta"
    
    if [[ -r "$cache_file" && -r "$meta_file" ]]; then
        touch "$cache_file" "$meta_file" 2>/dev/null || true
        echo "$cache_file"
        return 0
    fi
    
    return 1
}

# Check if file has cached version (without generating)
has_cached_preview() {
    check_file_cached "$@"
}

# Get cached version or generate if needed
get_cached_preview() {
    local file="$1"
    local mime_type="$2"

    # Skip cache directory files  
    [[ "${file#$CACHE_DIR}" != "$file" ]] && return 1
    
    # Quick mime type validation for cacheable formats
    case "$mime_type" in
        image/png)
            # For PNG, check if it needs caching (skip if already small)
            if command -v magick >/dev/null 2>&1; then
                local dimensions width height
                dimensions=$(timeout 2s magick identify -format "%w %h" "$file" 2>/dev/null || echo "0 0")
                read -r width height <<< "$dimensions"
                if [[ $width -le $IMAGE_CACHE_WIDTH && $height -le $IMAGE_CACHE_HEIGHT && $width -gt 0 ]]; then
                    return 1  # Already optimally sized
                fi
            fi
            ;;
        image/jpeg|image/jpg|image/webp|image/heic|image/gif|image/*|*/pdf|image/vnd.djvu|video/*|font/*|application/vnd.ms-opentype)
            ;;
        *)
            return 1
            ;;
    esac

    # Determine resolution based on content type
    local target_width target_height
    case "$mime_type" in
        */pdf | image/vnd.djvu | font/* | application/vnd.ms-opentype)
            target_width=$TEXT_CACHE_WIDTH
            target_height=$TEXT_CACHE_HEIGHT
            ;;
        *)
            target_width=$IMAGE_CACHE_WIDTH
            target_height=$IMAGE_CACHE_HEIGHT
            ;;
    esac

    # Generate cache key inline
    local file_stat cache_input cache_key
    file_stat=$(stat -c "%Y-%s-%n" "$file" 2>/dev/null || echo "missing")
    cache_input="${file_stat}-${target_width}x${target_height}"
    cache_key=$(echo "$cache_input" | sha256sum | cut -d' ' -f1)

    # Check for existing cache
    local cache_file="$CACHE_DIR/images/${cache_key}.png"
    local meta_file="$CACHE_DIR/metadata/${cache_key}.meta"
    
    if [[ -r "$cache_file" && -r "$meta_file" ]]; then
        # Update access time for LRU cleanup
        touch "$cache_file" "$meta_file" 2>/dev/null || true
        echo "$cache_file"
        return 0
    fi

    # Generate cache
    local is_text_content=0
    case "$mime_type" in
        */pdf | image/vnd.djvu | font/* | application/vnd.ms-opentype)
            is_text_content=1
            ;;
    esac
    
    if generate_cache "$file" "$mime_type" "$is_text_content" >/dev/null; then
        # Check cache size and cleanup if needed after generating new content
        check_and_cleanup_cache &
        echo "$cache_file"
        return 0
    fi

    return 1
}

# Preemptive caching for current directory (background)
# Smart preemptive caching with concurrency control
precache_directory() {
    local dir="$1"
    local priority_file="$2"  # Optional: file to prioritize
    local script_path="${BASH_SOURCE[0]}"

    # Skip caching if we're in the cache directory itself
    [[ "${dir#$CACHE_DIR}" != "$dir" ]] && return 0

    # Simple lock mechanism - use directory hash for uniqueness
    local dir_hash=$(echo "$dir" | sha256sum | cut -d' ' -f1 | cut -c1-16)
    local lock_file="$CACHE_DIR/locks/precache_${dir_hash}.lock"
    
    # Check if preemptive caching is already running for this directory
    if [[ -f "$lock_file" ]] && kill -0 $(cat "$lock_file" 2>/dev/null) 2>/dev/null; then
        # Already running - just return
        return 0
    fi

    # Create/update lock file with our PID
    echo $$ > "$lock_file"
    
    # Export variables for the background script
    export PRECACHE_DIR="$dir"
    export PRECACHE_PRIORITY="$priority_file"
    export PRECACHE_SCRIPT="$script_path"
    export PRECACHE_LOCK="$lock_file"
    export PRECACHE_MAX_JOBS="$MAX_THREADS"
    
    # Start smart preemptive caching in background with very low priority
    nice -n 19 ionice -c 3 bash -c '
        # Clean up lock on exit
        trap "rm -f \"$PRECACHE_LOCK\"" EXIT
        
        # Find cacheable files, priority file first
        declare -a files=()
        if [[ -n "$PRECACHE_PRIORITY" && -f "$PRECACHE_PRIORITY" ]]; then
            files+=("$PRECACHE_PRIORITY")
        fi
        
        # Add other files to array
        while IFS= read -r -d "" file; do
            [[ "$file" != "$PRECACHE_PRIORITY" ]] && files+=("$file")
        done < <(find "$PRECACHE_DIR" -maxdepth 1 -type f \( \
            -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o \
            -iname "*.heic" -o -iname "*.gif" -o -iname "*.pdf" -o \
            -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" \) \
            -print0 2>/dev/null)
        
        # Process files with limited concurrency
        job_count=0
        declare -a pids=()
        
        for file in "${files[@]}"; do
            # Wait if we have too many jobs running
            while [[ $job_count -ge $PRECACHE_MAX_JOBS ]]; do
                for i in "${!pids[@]}"; do
                    if ! kill -0 "${pids[i]}" 2>/dev/null; then
                        unset "pids[i]"
                        job_count=$((job_count - 1))
                    fi
                done
                pids=("${pids[@]}")  # Reindex array
                [[ $job_count -ge $PRECACHE_MAX_JOBS ]] && sleep 0.1
            done
            
            # Start caching job
            (
                source "$PRECACHE_SCRIPT" 2>/dev/null || exit 1
                mime_type=$(file --dereference --brief --mime-type -- "$file" 2>/dev/null || echo "unknown")
                get_cached_preview "$file" "$mime_type" >/dev/null 2>&1
            ) &
            
            pids+=($!)
            job_count=$((job_count + 1))
            
            # Small delay to be nice to the system
            sleep 0.05
        done
        
        # Wait for all jobs to complete
        for pid in "${pids[@]}"; do
            wait "$pid" 2>/dev/null || true
        done
    ' &
}

# Get current cache size in MB
get_cache_size_mb() {
    if [[ -d "$CACHE_DIR" ]]; then
        # Force sync to update filesystem metadata
        sync 2>/dev/null || true
        du -sm "$CACHE_DIR" 2>/dev/null | cut -f1 || echo "0"
    else
        echo "0"
    fi
}

# Cleanup cache using LRU policy - remove oldest accessed files until target size
cleanup_cache_lru() {
    local current_size_mb
    current_size_mb=$(get_cache_size_mb)
    
    if [[ $current_size_mb -le $TARGET_CACHE_SIZE_MB ]]; then
        return 0  # Already under target size
    fi
    
    echo "Cache cleanup: $current_size_mb MB > $TARGET_CACHE_SIZE_MB MB target, removing LRU files..." >&2
    
    # Get list of cache files sorted by access time (oldest first)
    local files_deleted=0
    
    # Use array to avoid pipe issues
    mapfile -t files_to_delete < <(find "$CACHE_DIR/images" -name "*.png" -type f -printf '%A@ %p\n' 2>/dev/null | sort -n | cut -d' ' -f2-)
    
    for cache_file in "${files_to_delete[@]}"; do
        current_size_mb=$(get_cache_size_mb)
        if [[ $current_size_mb -le $TARGET_CACHE_SIZE_MB ]]; then
            break  # Reached target size
        fi
        
        if [[ -f "$cache_file" ]]; then
            local cache_key
            cache_key=$(basename "$cache_file" .png)
            local meta_file="$CACHE_DIR/metadata/${cache_key}.meta"
            
            # Remove both image and metadata
            rm -f "$cache_file" "$meta_file" 2>/dev/null
            ((files_deleted++))
        fi
    done
    
    local final_size_mb
    final_size_mb=$(get_cache_size_mb)
    echo "Cache cleanup complete: removed $files_deleted files, size: $final_size_mb MB" >&2
}

# Check cache size and cleanup if needed
check_and_cleanup_cache() {
    local current_size_mb
    current_size_mb=$(get_cache_size_mb)
    
    if [[ $current_size_mb -gt $MAX_CACHE_SIZE_MB ]]; then
        cleanup_cache_lru
    fi
}

# Export functions for use by preview script
export -f generate_cache get_cached_preview has_cached_preview check_file_cached precache_directory
export -f get_cache_size_mb cleanup_cache_lru check_and_cleanup_cache
