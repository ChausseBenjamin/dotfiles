# LF Smart Cache System 🚀

A focused, efficient caching system for lf previews with intelligent format handling.

## 🎯 **Smart Caching Rules**

### **What Gets Cached:**
- **Images (JPEG, WebP, HEIC, GIF)**: → 720p PNG cache
- **Large PNGs (>720p)**: → 720p PNG cache  
- **PDFs & DjVu**: → 1080p PNG cache (high-res for text clarity)
- **Videos**: → 720p PNG thumbnail cache
- **Fonts**: → 720p PNG preview cache

### **What Doesn't Get Cached:**
- **Small PNGs (≤720p)**: Displayed directly (no point caching)
- **Files in cache directory**: Prevents recursive caching
- **Text files**: Too small to benefit from caching

## ⚡ **Performance Features**

### **Cache Hit/Miss Logic:**
- **Cache Hit**: Instant display from cached 720p/1080p PNG
- **Cache Miss**: Generate cache in background, display original
- **LRU Management**: Access time tracking for cleanup

### **Preemptive Caching:**
- **4 parallel threads** cache other files in current directory
- **Background processing** doesn't slow down current preview
- **Smart limits**: Max 20 files per directory scan

### **Quality Optimizations:**
- **720p cache**: Sharp enough for preview, fast to load
- **1080p for PDFs**: Maximum text clarity for documents  
- **Mitchell filter**: Superior downsampling algorithm
- **PNG format**: Kitty's fastest rendering format

## 🛠️ **Usage**

### **Cache Management:**
```bash
./lfcache stats    # Show cache statistics
./lfcache clear    # Clear entire cache  
./lfcache clean    # Remove old entries (>30 days)
```

### **Configuration:**
Edit `cache_system.sh` to adjust:
```bash
IMAGE_CACHE_WIDTH=1280     # 720p width
IMAGE_CACHE_HEIGHT=720     # 720p height
TEXT_CACHE_WIDTH=1920      # 1080p width for PDFs
TEXT_CACHE_HEIGHT=1080     # 1080p height for PDFs
MAX_THREADS=4              # Preemptive caching threads
```

## 📊 **Example Performance**

**Your 32MB JPEG:**
- **First view**: Normal speed (generating 720p PNG cache)
- **Second view**: **Instant** (cached 720p PNG display)
- **Directory browsing**: Other JPEGs pre-cached in background

**PDF Documents:**  
- **Cached at 1080p** for crisp text rendering
- **300 DPI source** → 1080p PNG for maximum clarity

## 🏗️ **Architecture**

```
Original File → Cache Check → [Hit: Display Cache] 
                          ↓
                    [Miss: Generate Cache + Display]
                          ↓
                    Background: Precache Directory
```

**Cache Structure:**
```
~/.cache/lf-previews/
├── images/          # Cached PNG files (720p/1080p)
├── metadata/        # Cache metadata & timestamps  
└── locks/           # Process synchronization
```

The system is designed to be **fast, smart, and space-efficient** while providing crisp previews for all formats! 🎯