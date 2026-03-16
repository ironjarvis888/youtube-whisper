#!/bin/bash
# =============================================================================
# YouTube Whisper - 下載 YouTube 影片並轉文字
# =============================================================================
# Author: Kuanlin
# Description: 自動偵測字幕，有字幕則擷取，無字幕則用 Whisper 轉文字
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
MAX_DURATION_MINUTES=30
MAX_FILESIZE_GB=1

# =============================================================================
# 系統資源檢查函式 / System Resource Check Functions
# =============================================================================

# 取得可用記憶體 (GB) / Get available RAM in GB
get_available_ram_gb() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        vm_stat | grep "Pages free:" | awk '{print $3}' | xargs -I {} echo "scale=2; {} * 4096 / 1024 / 1024 / 1024" | bc 2>/dev/null || echo "0"
    else
        free -g | awk '/^Mem:/ {print $7}'
    fi
}

# 取得系統負載 / Get system load
get_system_load() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | tr -d '%' 2>/dev/null || echo "0"
    else
        uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs
    fi
}

# 檢查系統資源 / Check system resources
check_resources() {
    echo "🔍 正在檢查系統資源... / Checking system resources..."
    
    # 取得總記憶體 / Get total RAM
    if [[ "$OSTYPE" == "darwin"* ]]; then
        TOTAL_RAM=$(sysctl -n hw.memsize 2>/dev/null | awk '{print $1/1024/1024/1024}' || echo "0")
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
    
    # 檢查總記憶體 / Check if total RAM is sufficient
    if [ -n "$TOTAL_RAM" ] && (( $(echo "$TOTAL_RAM < $MIN_RAM_GB" | bc -l 2>/dev/null || echo "0") )); then
        echo "⚠️ 警告 / Warning: 系統記憶體不足 / System RAM insufficient"
        return 1
    fi
    
    # 檢查可用記憶體 / Check available RAM
    if [ -n "$AVAILABLE_RAM" ] && (( $(echo "$AVAILABLE_RAM < $MIN_AVAILABLE_RAM_GB" | bc -l 2>/dev/null || echo "0") )); then
        echo "⚠️ 警告 / Warning: 可用記憶體不足 / Available RAM low"
        echo "💡 建議關閉其他應用程式後再執行 / Tip: Close other apps before running"
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
# 字幕檢查函式 / Subtitle Check Functions
# =============================================================================

# 檢查是否有字幕 / Check if subtitles available
check_subtitles() {
    local url="$1"
    echo "🎬 正在檢查字幕... / Checking for subtitles..."
    
    # 取得字幕語言列表 / Get subtitle language list
    SUBTITLE_LANGS=$(yt-dlp --list-subs "$url" 2>/dev/null | grep -v "Has no subtitles" | head -20)
    
    if [ -z "$SUBTITLE_LANGS" ]; then
        echo "📝 結果: 無字幕 / Result: No subtitles"
        return 1  # No subtitles
    else
        echo "📝 結果: 有字幕 / Result: Has subtitles"
        echo "$SUBTITLE_LANGS"
        return 0  # Has subtitles
    fi
}

# 擷取字幕 / Extract subtitles
extract_subtitles() {
    local url="$1"
    local output="$2"
    
    echo "📥 正在擷取字幕... / Extracting subtitles..."
    
    # 嘗試擷取字幕 / Try to extract subtitles
    # 優先使用中文 / Prefer Chinese
    yt-dlp --write-subs --sub-lang "zh-TW,zh-CN,zh,cht,en" --skip-download --convert-subs "srt" -o "$output" "$url" 2>/dev/null
    
    # 嘗試轉換為文字 / Try to convert to text
    local srt_file="${output%.txt}.srt"
    
    if [ -f "$srt_file" ]; then
        # 簡單的 SRT 到文字轉換 / Simple SRT to text conversion
        sed -E '/^[0-9]+$/d;/^$/d' "$srt_file" > "$output"
        echo "✅ 字幕擷取完成 / Subtitle extraction complete"
        return 0
    else
        echo "❌ 字幕擷取失敗 / Subtitle extraction failed"
        return 1
    fi
}

# =============================================================================
# Whisper 轉文字函式 / Whisper Transcription Functions
# =============================================================================

# 用 Whisper 轉文字 / Transcribe with Whisper
transcribe_with_whisper() {
    local url="$1"
    local output="$2"
    local model="$3"
    
    echo "📥 正在下載 YouTube 影片..."
    TEMP_DIR="/tmp/youtube-whisper-$$"
    AUDIO_FILE="$TEMP_DIR/audio.m4a"
    mkdir -p "$TEMP_DIR"
    
    # 清理函式 / Cleanup function
    cleanup() {
        rm -rf "$TEMP_DIR"
    }
    trap cleanup EXIT
    
    # 下載音訊 / Download audio
    yt-dlp -f "bestaudio[ext=m4a]" -o "$AUDIO_FILE" "$url" --quiet 2>/dev/null
    
    echo "🔄 正在使用 Whisper 轉文字 (模型: $model)..."
    whisper "$AUDIO_FILE" --model "$model" --language zh --output_dir "$TEMP_DIR" --output_format txt 2>/dev/null
    
    # 尋找輸出檔案 / Find output file
    TRANSCRIPT_FILE=$(ls "$TEMP_DIR"/*.txt 2>/dev/null | head -1)
    
    if [ -n "$TRANSCRIPT_FILE" ] && [ -f "$TRANSCRIPT_FILE" ]; then
        cp "$TRANSCRIPT_FILE" "$output"
        echo "✅ Whisper 轉錄完成 / Whisper transcription complete"
        return 0
    else
        echo "❌ Whisper 轉錄失敗 / Whisper transcription failed"
        return 1
    fi
}

# =============================================================================
# 主程式 / Main Program
# =============================================================================

# 用法說明 / Usage
if [ -z "$URL" ]; then
    echo "用法 / Usage: youtube-whisper.sh <youtube_url> [output_file] [model]"
    echo "範例 / Example: youtube-whisper.sh 'https://www.youtube.com/watch?v=xxx' transcript.txt small"
    echo ""
    echo "邏輯 / Logic:"
    echo "   1. 檢查字幕 / Check subtitles"
    echo "   2. 有字幕 → 直接擷取 / Has subtitles → Extract"
    echo "   3. 無字幕 → 用 Whisper / No subtitles → Use Whisper"
    exit 1
fi

# 預設輸出檔名 / Default output filename
if [ -z "$OUTPUT" ]; then
    OUTPUT="transcript_$(date +%Y%m%d_%H%M%S).txt"
fi

# 取得影片標題 / Get video title
VIDEO_TITLE=$(yt-dlp --print "%(title)s" -s "$URL" 2>/dev/null | head -1)
echo "📺 標題 / Title: $VIDEO_TITLE"

# 檢查系統資源 (Whisper 需要) / Check system resources (needed for Whisper)
check_resources
RESOURCES_OK=$?

# 檢查字幕 / Check for subtitles
check_subtitles "$URL"
HAS_SUBTITLES=$?

if [ $HAS_SUBTITLES -eq 0 ]; then
    # 有字幕 - 嘗試擷取 / Has subtitles - try to extract
    echo ""
    echo "🎯 使用字幕方式 / Using subtitle method"
    extract_subtitles "$URL" "$OUTPUT"
    EXTRACT_OK=$?
    
    if [ $EXTRACT_OK -eq 0 ]; then
        echo ""
        echo "✅ 完成！字幕已儲存至 / Done! Saved to: $OUTPUT"
        cat "$OUTPUT"
    else
        # 字幕擷取失敗，嘗試 Whisper / Subtitle extraction failed, try Whisper
        echo "⚠️ 字幕擷取失敗，嘗試 Whisper... / Subtitle extraction failed, trying Whisper..."
        
        if [ $RESOURCES_OK -ne 0 ]; then
            echo "❌ 系統資源不足，無法使用 Whisper / Insufficient resources for Whisper"
            exit 1
        fi
        
        transcribe_with_whisper "$URL" "$OUTPUT" "$MODEL"
    fi
else
    # 無字幕 - 使用 Whisper / No subtitles - use Whisper
    echo ""
    echo "🎯 無字幕，使用 Whisper 轉文字 / No subtitles, using Whisper"
    
    if [ $RESOURCES_OK -ne 0 ]; then
        echo "❌ 系統資源不足，無法使用 Whisper / Insufficient resources for Whisper"
        exit 1
    fi
    
    transcribe_with_whisper "$URL" "$OUTPUT" "$MODEL"
    
    if [ -f "$OUTPUT" ]; then
        echo ""
        echo "✅ 完成！轉錄已儲存至 / Done! Saved to: $OUTPUT"
        cat "$OUTPUT"
    fi
fi
