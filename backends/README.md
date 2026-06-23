# ASR backends

`meeting` transcribes with a pluggable backend selected by **`MEETING_ASR`** (default `whisper`,
fully local & offline). Cloud backends upload audio to a provider and need an API key — `meeting`
prints a warning when you pick one. **Keys are read from environment variables and never stored
in this repo.**

## Contract
A backend is `backends/<name>.sh`, invoked as `<name>.sh <audio> <out_base> <lang>`:
- env: `$MEETING_PROMPT_TEXT` (glossary, may be empty) + your provider key
- MUST write `<out_base>.txt`; SHOULD write `<out_base>.srt` (timestamps; prefix `Speaker N:` if diarized)
- exit 0 on success

Add one by copying [`_template.sh`](_template.sh) and selecting it with `MEETING_ASR=<name>`.

## Built-in
| `MEETING_ASR` | tier | key env | notes |
|---|---|---|---|
| `whisper` *(default)* | local | — | whisper.cpp; offline, private |
| `faster-whisper` | local | — | `pip install faster-whisper`; model via `MEETING_FW_MODEL` (default `large-v3`) |
| `openai` | cloud | `OPENAI_API_KEY` | `whisper-1` → .txt + .srt; set `MEETING_OPENAI_MODEL=gpt-4o-transcribe` for higher accuracy (text only) |
| `deepgram` | cloud | `DEEPGRAM_API_KEY` | Nova-3 + **diarization** (speaker labels in .srt); model via `MEETING_DEEPGRAM_MODEL` |

## Wanted — best for Chinese (contributions welcome)
These have top Chinese accuracy + built-in speaker separation, but use signed / multi-step auth and
need a real key to verify, so they ship as a template slot rather than unverified code:
- **`xfyun`** (讯飞 / iFlytek) · **`alibaba`** (DashScope / Paraformer) · `assemblyai` · `elevenlabs`

Start from [`_template.sh`](_template.sh). PRs welcome.

## Privacy
The default `whisper` keeps everything on your machine. Any cloud backend sends your audio to a
third party — only use one where that's acceptable. `meeting` warns before doing so.
