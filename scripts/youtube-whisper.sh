#!/bin/bash
# YouTube Whisper - Download and transcribe YouTube videos
# Usage: youtube-whisper.sh <url> [output_file] [model]

set -e

URL="${1:-}"
OUTPUT="${2:-}"
MODEL="${3:-small}"

if [ -z "$URL" ]; then
    echo "Usage: youtube-whisper.sh <youtube_url> [output_file] [model]"
    echo "Example: youtube-whisper.sh 'https://www.youtube.com/watch?v=xxx' transcript.txt small"
    exit 1
fi

# Default output filename
if [ -z "$OUTPUT" ]; then
    OUTPUT="transcript_$(date +%Y%m%d_%H%M%S).txt"
fi

TEMP_DIR="/tmp/youtube-whisper-$$"
VIDEO_FILE="$TEMP_DIR/video.mp4"
AUDIO_FILE="$TEMP_DIR/audio.m4a"

mkdir -p "$TEMP_DIR"

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "📥 Downloading YouTube video..."
yt-dlp -f "bestaudio[ext=m4a]" -o "$AUDIO_FILE" "$URL" --quiet

echo "🔄 Transcribing with Whisper (model: $MODEL)..."
# Default to Traditional Chinese (zh-TW / zh)
whisper "$AUDIO_FILE" --model "$MODEL" --language zh --output_dir "$TEMP_DIR" --output_format txt 2>/dev/null

# Find the output file
TRANSCRIPT_FILE=$(ls "$TEMP_DIR"/*.txt 2>/dev/null | head -1)

if [ -n "$TRANSCRIPT_FILE" ] && [ -f "$TRANSCRIPT_FILE" ]; then
    cp "$TRANSCRIPT_FILE" "$OUTPUT"
    echo "✅ Done! Transcript saved to: $OUTPUT"
    cat "$OUTPUT"
else
    echo "❌ Error: Transcription failed"
    exit 1
fi
