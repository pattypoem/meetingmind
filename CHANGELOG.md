# Changelog

All notable changes to this project are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/).

## [0.1.0] — unreleased

### Added
- Core CLI `meeting`: `rec` (foreground recorder + live level meter), `start`/`stop` (background,
  cross-window), `status`, `transcribe`, `recover`, `glossary`, `devices`, `setup`.
- Local transcription via whisper.cpp (ggml-large-v3-turbo), Metal-accelerated on Apple Silicon.
- Context-aware glossary fed to whisper `--prompt`; the Claude Code agent maintains it from editor
  memory / repo / past notes so transcripts spell your domain terms right.
- Claude Code skill (`/meeting`) that records → transcribes → summarizes (summary / decisions /
  action items) and files notes to `~/.meeting/notes/`.
- Robustness: verified start (catches denied mic permission), `MEETING_MAX_MIN` auto-stop cap,
  low-disk warning, atomic model download, and crash recovery (`meeting recover`).
- Timestamped `.srt` output alongside `.txt`; transcription is safely interruptible (Ctrl-C tells
  you the audio is saved and how to resume).
- Pluggable ASR backends via `MEETING_ASR`: local `whisper` (default) / `faster-whisper`, cloud
  `openai` / `deepgram` (bring-your-own-key, with a privacy warning); `backends/` extension point
  (讯飞 / 阿里 scaffolded as wanted contributions).
- Anti-hallucination for local whisper: Silero VAD (skips silence) + `-sns` + `--suppress-regex`
  kill the silence-hallucination loops (repeated 请点赞 / 感谢观看 / stuck phrases). `MEETING_VAD=0`
  to disable; VAD model auto-downloaded by `meeting setup`.

### Known limitations
- macOS / Apple Silicon only; no speaker diarization; no Zoom system-audio capture yet.
