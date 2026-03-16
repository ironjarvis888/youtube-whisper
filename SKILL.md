---
name: youtube-whisper
description: Download YouTube videos and transcribe audio using local Whisper. Use when you need to extract text from YouTube videos that don't have subtitles, or when youtube-watcher fails due to missing captions.
---

# YouTube Whisper

Download YouTube videos and transcribe audio using local Whisper.

## When to Use

- YouTube video has no subtitles
- youtube-watcher fails due to missing captions
- Need offline transcription
- High-quality local transcription (better than YouTube auto-captions)

## Usage

```bash
# Basic transcription
youtube-whisper.sh "https://www.youtube.com/watch?v=VIDEO_ID"

# Specify output filename
youtube-whisper.sh "URL" "output.txt"

# Use specific Whisper model (tiny, base, small, medium, large)
# Default language: Traditional Chinese (zh)
youtube-whisper.sh "URL" "output.txt" "small"
```

## Requirements

- yt-dlp: `brew install yt-dlp`
- Whisper: `pip3 install openai-whisper` or use openai-whisper skill
- ffmpeg: `brew install ffmpeg`

## Output

Transcription text file in the same directory.

## Notes

- Videos are downloaded to /tmp and cleaned up after transcription
- Default model: small (good balance of speed and accuracy)
- Larger models (medium, large) are slower but more accurate
