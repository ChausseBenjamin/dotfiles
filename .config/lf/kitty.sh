#!/bin/bash

# Transmits an image in png format via file-mode transmission.
#   $1 file path
#   $2 image id
transmit_file_png() {
	abspath_b64="$(printf -- "$(realpath -- "$1")" | base64 -w0)"
	printf "\e_Gt=f,i=$2,f=100,q=1;$abspath_b64\e\\" >/dev/tty
}

# Displays an already transferred image.
#   $1 image id
#   $2 placement id
#   $3 x, $4 y, $5 w, $6 h
display_img() {
    printf "\e[s" >/dev/tty # save cursor position
    tput cup $4 $3 >/dev/tty # move cursor
    printf "\e_Ga=p,i=$1,p=$2,c=$5,r=$6,q=1\e\\" >/dev/tty
    printf "\e[u" >/dev/tty # restore cursor position
}

# Deletes a displayed image.
#   $1 image id
#   $2 placement id
delete_img() {
	printf "\e_Ga=d,d=I,i=$1,p=$2,q=1\e\\" >/dev/tty
}

# Combines transmit_file_png and display_img.
#   $1 file path
#   $2 image id
#   $3 placement id
#   $4 x, $5 y, $6 w, $7 h
show() {
    local img_width img_height new_width new_height
    img_width=$(identify -format "%w" "$1")
    img_height=$(identify -format "%h" "$1")
    
    # Debug output to file
    echo "DEBUG: Image=${img_width}x${img_height}, Preview=${6}x${7}" >> /tmp/lf_debug.log
    
    # Calculate scale factors for both dimensions
    local scale_w scale_h
    scale_w=$(awk "BEGIN {print $6 / $img_width}")
    scale_h=$(awk "BEGIN {print $7 / $img_height}")
    
    echo "DEBUG: Scale factors - width: $scale_w, height: $scale_h" >> /tmp/lf_debug.log
    
    # Use the SMALLER scale factor to ensure it fits in both dimensions
    if (( $(awk "BEGIN {print ($scale_w < $scale_h)}") )); then
        # Width scale is smaller - width constrained
        new_width=$6
        new_height=$(awk "BEGIN {printf \"%.0f\", $img_height * $scale_w}")
        echo "DEBUG: Using width scale (smaller) -> ${new_width}x${new_height}" >> /tmp/lf_debug.log
    else
        # Height scale is smaller - height constrained
        new_height=$7
        new_width=$(awk "BEGIN {printf \"%.0f\", $img_width * $scale_h}")
        echo "DEBUG: Using height scale (smaller) -> ${new_width}x${new_height}" >> /tmp/lf_debug.log
    fi
    
    # Verify aspect ratio
    local final_aspect original_aspect
    original_aspect=$(awk "BEGIN {printf \"%.6f\", $img_width / $img_height}")
    final_aspect=$(awk "BEGIN {printf \"%.6f\", $new_width / $new_height}")
    echo "DEBUG: Original aspect: $original_aspect, Final aspect: $final_aspect" >> /tmp/lf_debug.log
    echo "DEBUG: Final -> ${new_width}x${new_height}" >> /tmp/lf_debug.log
    echo "---" >> /tmp/lf_debug.log
    
    transmit_file_png "$1" "$2"
    display_img "$2" "$3" "$4" "$5" "$new_width" "$new_height"
}

"$@"
