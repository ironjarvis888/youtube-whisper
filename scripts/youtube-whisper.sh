#!/bin/bash
# =============================================================================
# YouTube Whisper - 下載 YouTube 影片並用 Whisper 轉文字
# =============================================================================
# Author: Kuanlin
# Description: 下載 YouTube 影片並使用本地 Whisper 進行語音轉文字
# Usage: youtube-whisper.sh <url> [output_file] [model]
# =============================================================================

set -e

# 參數設定 / Parameters
URL="${1:-}"
OUTPUT="${2:-}"
MODEL="${3:-small}"

# 最低需求 / Minimum requirements
MIN_RAM_GB=4
MIN_AVAILABLE_RAM_GB=2

# 影片限制 / Video limits
MAX_DURATION_MINUTES=30      # 最長 30 分鐘
MAX_FILESIZE_GB=1           # 最大 1GB

# =============================================================================
# 系統資源檢查函式 / System Resource Check Functions
# =============================================================================

# 取得可用記憶體 (GB) / Get available RAM in GB
get_available_ram_gb() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        vm_stat | grep "Pages free:" | awk '{print $3}' | xargs -I {} echo "scale=2; {} * 4096 / 1024 / 1024 / 1024" | bc
    else
        # Linux
        free -g | awk '/^Mem:/ {print $7}'
    fi
}

# 取得系統負載 / Get system load
get_system_load() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - 取得 CPU 使用率
        top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | tr -d '%'
    else
        # Linux
        uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs
    fi
}

# 檢查系統資源 / Check system resources
check_resources() {
    echo "🔍 正在檢查系統資源... / Checking system resources..."
    
    # 取得總記憶體 / Get total RAM
    if [[ "$OSTYPE" == "darwin"* ]]; then
        TOTAL_RAM=$(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024}')
    else
        TOTAL_RAM=$(free -g | awk '/^Mem:/ {print $2}')
    fi
    
    # 取得可用記憶體 / Get available RAM
    AVAILABLE_RAM=$(get_available_ram_gb)
    
    # 取得 CPU 使用率 / Get CPU usage
    CPU_LOAD=$(get_system_load)
    
    echo "📊 系統狀態 / System Status:"
    echo "   總記憶體 / Total RAM: ${TOTAL_RAM} GB"
    echo "   可用記憶體 / Available RAM: ${AVAILABLE_RAM} GB"
    echo "   CPU 使用率 / CPU Usage: ${CPU_LOAD}%"
    
    # 檢查總記憶體是否足夠 / Check if total RAM is sufficient
    if (( $(echo "$TOTAL_RAM < $MIN_RAM_GB" | bc -l) )); then
        echo "⚠️ 警告 / Warning: 系統記憶體不足 / System RAM insufficient (需要 / Need: ${MIN_RAM_GB} GB)"
        return 1
    fi
    
    # 檢查可用記憶體 / Check available RAM
    if (( $(echo "$AVAILABLE_RAM < $MIN_AVAILABLE_RAM_GB" | bc -l) )); then
        echo "⚠️ 警告 / Warning: 可用記憶體不足 / Available RAM low (低於 / Below: ${MIN_AVAILABLE_RAM_GB} GB)"
        echo "💡 建議關閉其他應用程式後再執行 / Tip: Close other apps before running"
        read -p "是否繼續執行? / Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ 已取消執行 / Execution cancelled"
            exit 0
        fi
    fi
    
    # 檢查 CPU 負載 / Check CPU load (如果過高則警告 / Warn if too high)
    if (( $(echo "$CPU_LOAD > 80" | bc -l) )); then
        echo "⚠️ 警告 / Warning: CPU 使用率高 / High CPU usage (${CPU_LOAD}%)"
        echo "💡 系統可能會變慢 / System may be slow"
        read -p "是否繼續執行? / Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ 已取消執行 / Execution cancelled"
            exit 0
        fi
    fi
    
    echo "✅ 系統資源檢查通過 / System resources OK"
    return 0
}

# =============================================================================
# 影片資訊檢查 / Video Info Check
# =============================================================================

# 取得影片時長 (分鐘) / Get video duration in minutes
get_video_duration_minutes() {
    local url="$1"
    yt-dlp --print "%duration%" -s "$url" 2>/dev/null | awk '{print int($1/60)}'
}

# 取得影片檔案大小 (GB) / Get video file size in GB
get_video_filesize_gb() {
    local url="$1"
    yt-dlp -f "bestaudio[ext=m4a]" --print "%filesize%" -s "$url" 2>/dev/null | awk '{print $1/1024/1024/1024}'
}

# 檢查影片是否為語音為主 / Check if video is speech-based (not just music)
check_audio_content() {
    local audio_file="$1"
    echo "🎵 正在分析音訊內容... / Analyzing audio content..."
    
    # 使用 ffprobe 檢測音訊類型
    # 檢查音訊軌道的編碼和特性
    AUDIO_CODEC=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of csv=p=0 "$audio_file" 2>/dev/null)
    
    # 檢查是否有語音 / Check for speech patterns
    # 如果沒有音頻軌道，回覆沒有語音
    if [ -z "$AUDIO_CODEC" ]; then
        echo "⚠️ 警告: 無法偵測音軌 / Warning: No audio track detected"
        return 2
    fi
    
    echo "   音訊編碼 / Audio codec: $AUDIO_CODEC"
    
    # 簡單判斷：如果只有背景音樂可能沒有語音
    # 這是一個簡單的檢查，更準確的方法需要語音偵測模型
    echo "💡 提示: 如果影片是純音樂，轉錄結果可能為空 / Tip: If video is pure music, transcript may be empty"
    
    return 0
}

# 檢查影片限制 / Check video limits
check_video_limits() {
    local url="$1"
    echo "🎬 正在檢查影片... / Checking video..."
    
    # 取得影片標題 / Get video title
    VIDEO_TITLE=$(yt-dlp --print "%(title)s" -s "$url" 2>/dev/null | head -1)
    echo "   標題 / Title: $VIDEO_TITLE"
    
    # 取得時長 / Get duration
    DURATION_SEC=$(yt-dlp --print "%duration%" -s "$url" 2>/dev/null | head -1)
    DURATION_MIN=$((DURATION_SEC / 60))
    
    echo "   時長 / Duration: ${DURATION_MIN} 分鐘 / minutes"
    
    # 檢查時長限制 / Check duration limit
    if [ "$DURATION_MIN" -gt "$MAX_DURATION_MINUTES" ]; then
        echo "⚠️ 影片過長 / Video too long: ${DURATION_MIN} 分鐘 (最大 / Max: ${MAX_DURATION_MINUTES} 分鐘)"
        echo "💡 建議使用分段下載或選擇較短的影片 / Tip: Use shorter videos or download in segments"
        
        # 詢問用戶是否繼續 / Ask user if they want to continue
        read -p "是否繼續執行? (可能需要較長時間) / Continue anyway? (may take long time) (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ 已取消執行 / Execution cancelled"
            exit 0
        fi
    fi
    
    # 取得預期檔案大小 (可能不準確) / Get estimated file size (may be inaccurate)
    ESTIMATED_SIZE=$(yt-dlp -f "bestaudio[ext=m4a]" --print "%(filesize,filesize_approx)s" -s "$url" 2>/dev/null | head -1)
    
    if [ -n "$ESTIMATED_SIZE" ] && [ "$ESTIMATED_SIZE" != "NA" ]; then
        SIZE_GB=$((ESTIMATED_SIZE / 1024 / 1024 / 1024))
        echo "   預估大小 / Estimated size: ${SIZE_GB} GB"
        
        if [ "$SIZE_GB" -gt "$MAX_FILESIZE_GB" ]; then
            echo "⚠️ 檔案可能過大 / File may be too large: ${SIZE_GB} GB"
            read -p "是否繼續執行? / Continue anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "❌ 已取消執行 / Execution cancelled"
                exit 0
            fi
        fi
    fi
    
    echo "✅ 影片檢查通過 / Video check passed"
    return 0
}

# =============================================================================
# 主程式 / Main Program
# =============================================================================

# 用法說明 / Usage
if [ -z "$URL" ]; then
    echo "用法 / Usage: youtube-whisper.sh <youtube_url> [output_file] [model]"
    echo "範例 / Example: youtube-whisper.sh 'https://www.youtube.com/watch?v=xxx' transcript.txt small"
    echo ""
    echo "限制 / Limits:"
    echo "   最長時長 / Max duration: ${MAX_DURATION_MINUTES} 分鐘 / minutes"
    echo "   最大檔案 / Max file size: ${MAX_FILESIZE_GB} GB"
    exit 1
fi

# 檢查系統資源 / Check system resources
check_resources

# 檢查影片限制 / Check video limits
check_video_limits "$URL"

# 預設輸出檔名 / Default output filename
if [ -z "$OUTPUT" ]; then
    OUTPUT="transcript_$(date +%Y%m%d_%H%M%S).txt"
fi

# 暫存目錄 / Temporary directory
TEMP_DIR="/tmp/youtube-whisper-$$"
AUDIO_FILE="$TEMP_DIR/audio.m4a"

mkdir -p "$TEMP_DIR"

# 清理函式 / Cleanup function - 執行完畢後刪除暫存檔
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# 下載 YouTube 影片 / Download YouTube video
echo "📥 正在下載 YouTube 影片..."
yt-dlp -f "bestaudio[ext=m4a]" -o "$AUDIO_FILE" "$URL" --quiet 2>/dev/null

# 檢查音訊內容 / Check audio content
check_audio_content "$AUDIO_FILE"
AUDIO_CHECK=$?

if [ $AUDIO_CHECK -eq 2 ]; then
    echo "⚠️ 無法偵測音軌，無法轉錄 / Cannot detect audio track, cannot transcribe"
    exit 1
fi

# 用戶確認 / User confirmation for audio
if [ $AUDIO_CHECK -ne 0 ]; then
    read -p "偵測到可能為非語音內容，是否繼續? / Non-speech content detected, continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 已取消執行 / Execution cancelled"
        exit 0
    fi
fi

# 使用 Whisper 轉文字 / Transcribe with Whisper
# 預設語言: 繁體中文 (zh)
echo "🔄 正在使用 Whisper 轉文字 (模型: $MODEL)..."
whisper "$AUDIO_FILE" --model "$MODEL" --language zh --output_dir "$TEMP_DIR" --output_format txt 2>/dev/null

# 尋找輸出檔案 / Find output file
TRANSCRIPT_FILE=$(ls "$TEMP_DIR"/*.txt 2>/dev/null | head -1)

# 複製結果 / Copy result
if [ -n "$TRANSCRIPT_FILE" ] && [ -f "$TRANSCRIPT_FILE" ]; then
    cp "$TRANSCRIPT_FILE" "$OUTPUT"
    echo "✅ 完成！轉錄文字已儲存至 / Done! Transcript saved to: $OUTPUT"
    cat "$OUTPUT"
else
    echo "❌ 錯誤：轉錄失敗 / Error: Transcription failed"
    echo "💡 可能是純音樂影片，沒有語音內容 / Possible cause: pure music video, no speech content"
    exit 1
fi
