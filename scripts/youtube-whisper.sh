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

# 用法說明 / Usage
if [ -z "$URL" ]; then
    echo "用法 / Usage: youtube-whisper.sh <youtube_url> [output_file] [model]"
    echo "範例 / Example: youtube-whisper.sh 'https://www.youtube.com/watch?v=xxx' transcript.txt small"
    exit 1
fi

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
