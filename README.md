# YouTube Whisper / YouTube Whisper 語音轉文字

[English](#english) | [繁體中文](#繁體中文)

---

## English

### Description

Download YouTube videos and transcribe audio using local Whisper. Best for videos without subtitles.

### Features

- Download YouTube video audio
- Local Whisper transcription (no API needed)
- Default: Traditional Chinese output
- Multiple Whisper models support

### Requirements

```bash
# Install dependencies
brew install yt-dlp ffmpeg

# Install Whisper
pip3 install openai-whisper

# Or use openai-whisper skill
clawhub install openai-whisper
```

### Usage

```bash
# Basic transcription
./scripts/youtube-whisper.sh "https://www.youtube.com/watch?v=VIDEO_ID"

# With output file
./scripts/youtube-whisper.sh "URL" "output.txt"

# With specific model
./scripts/youtube-whisper.sh "URL" "output.txt" "small"
```

### Model Options

| Model | Speed | Accuracy |
|-------|-------|----------|
| tiny | Fastest | Lower |
| base | Fast | Medium |
| **small** | Medium | Good |
| medium | Slow | Better |
| large | Slowest | Best |

### Author

Kuanlin

---

## 繁體中文

### 說明

下載 YouTube 影片並使用本地 Whisper 進行語音轉文字。最適合沒有字幕的影片。

### 功能

- 下載 YouTube 影片音訊
- 本地 Whisper 轉錄 (無需 API)
- 預設：繁體中文輸出
- 支援多種 Whisper 模型

### 需求

```bash
# 安裝依賴
brew install yt-dlp ffmpeg

# 安裝 Whisper
pip3 install openai-whisper

# 或使用 openai-whisper 技能
clawhub install openai-whisper
```

### 使用方式

```bash
# 基本轉錄
./scripts/youtube-whisper.sh "https://www.youtube.com/watch?v=VIDEO_ID"

# 指定輸出檔案
./scripts/youtube-whisper.sh "網址" "輸出.txt"

# 指定模型
./scripts/youtube-whisper.sh "網址" "輸出.txt" "small"
```

### 模型選項

| 模型 | 速度 | 準確度 |
|------|------|--------|
| tiny | 最快 | 較低 |
| base | 快 | 中等 |
| **small** | 中等 | 良好 |
| medium | 慢 | 較高 |
| large | 最慢 | 最高 |

### 作者

Kuanlin

---

## License / 授權

MIT
