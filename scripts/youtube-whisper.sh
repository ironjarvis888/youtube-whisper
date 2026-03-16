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
# 主程式 / Main Program
# =============================================================================

# 用法說明 / Usage
if [ -z "$URL" ]; then
    echo "用法 / Usage: youtube-whisper.sh <youtube_url> [output_file] [model]"
    echo "範例 / Example: youtube-whisper.sh 'https://www.youtube.com/watch?v=xxx' transcript.txt small"
    exit 1
fi

# 檢查系統資源 / Check system resources
check_resources

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
    exit 1
fi
