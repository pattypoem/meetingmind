# MeetingMind

> Agent-native meeting notes for your terminal. Record locally, transcribe locally
> (whisper.cpp), and let your coding agent (Claude Code / Codex) do the summary,
> action-item extraction, and filing — with a glossary built from *your* context so
> it spells your jargon right.

![platform](https://img.shields.io/badge/platform-macOS%20Apple%20Silicon-black)
![license](https://img.shields.io/badge/license-MIT-blue)
![CI](https://github.com/pattypoem/meetingmind/actions/workflows/ci.yml/badge.svg)

**No app. No UI. No cloud.** One command in the terminal.

![demo](docs/demo.gif)

<sub>Illustrative demo (synthetic — no real meeting content). Record your own with the steps in <a href="CONTRIBUTING.md">CONTRIBUTING</a>.</sub>

## Why this, not another meeting app

The "local whisper + LLM summary" space is crowded (Granola, Hyprnote, Meetily, MacWhisper).
MeetingMind doesn't compete on UX. Its bet:

- **Lives where you already work** — a terminal agent, not a separate app.
- **Context-aware** — the agent builds a glossary from your editor memory / repo / past notes,
  so whisper spells *your* product names and teammates right, not a generic guess.
- **Agentic** — ask follow-ups about a transcript; the agent can act (file notes, open issues…).
- **Fully local & private** — recording + transcription never touch the network.

## Requirements

- **macOS on Apple Silicon** (current scope — see [Limitations](#limitations))
- `ffmpeg` — `brew install ffmpeg`
- `whisper.cpp` + a model — installed by `meeting setup`

## Install

```bash
git clone https://github.com/pattypoem/meetingmind
cd meetingmind
./install.sh        # symlinks bin/meeting to ~/.local/bin; installs the Claude Code skill
meeting setup       # brew install whisper-cpp + download model (~1.6GB)
```

## Two ways to use it (read this)

Recording is real-time; a terminal agent is turn-based. So there are **two modes that don't mix**:

```
┌─ meeting rec ── foreground · YOU run it in a terminal ──────────────┐
│  live level meter + timer · Ctrl-C stops & transcribes              │
│  ●REC 00:23  [███████████          ]  -18.4 LUFS   [Ctrl-C]         │
└──────────────────────────────────────────────────────────────────────┘
         ↓ then, in Claude Code:
   /meeting          → the agent summarizes the latest transcript

┌─ meeting start / stop ── background · for agents & scripts ─────────┐
│  detached recorder; stop from ANY window/session                    │
│  coordinates via files in ~/.meeting/ (not tied to a terminal)      │
└──────────────────────────────────────────────────────────────────────┘
```

- **`meeting rec`** — the human path. Holds the terminal, shows a live meter, stop with **Ctrl-C**
  there. It is **not** stopped by `meeting stop`.
- **`meeting start` + `meeting stop`** — the headless path. Start detached, stop from anywhere.
  This is the only pair where "start here, stop in another window" works.

## Commands

| command | what | where |
|---|---|---|
| `meeting rec` | foreground record + live meter; Ctrl-C → stop + transcribe | terminal (recommended) |
| `meeting start` / `meeting stop` | background record / stop + transcribe | any window |
| `meeting status` | recording? elapsed? warns about un-transcribed leftovers | any |
| `meeting transcribe [file]` | transcribe an audio file (or the last recording) | any |
| `meeting recover` | repair + transcribe recordings left by a crash/hard-kill | any |
| `meeting glossary` | show the term list fed to whisper | any |
| `meeting devices` | list audio input indices | any |
| `meeting setup` | install whisper.cpp + download the model | once |
| `/meeting [start\|stop\|<file>]` | Claude Code skill: runs the CLI **+ summarizes & files notes** | Claude Code |

## Configuration

| env | default | meaning |
|---|---|---|
| `MEETING_HOME` | `~/.meeting` | where recordings / models / notes / glossary live |
| `MEETING_MODEL` | `…/ggml-large-v3-turbo.bin` | whisper model (point at a smaller/quantized one for slower machines) |
| `MEETING_LANG` | `auto` | `zh` / `en` / `auto` |
| `MEETING_ASR` | `whisper` | transcription backend: `whisper`/`faster-whisper`/`openai`/`deepgram` — see [backends](backends/) |
| `MEETING_VAD` | `1` | skip silence via VAD to avoid whisper hallucination loops (`0` to disable) |
| `MEETING_AUDIO_INPUT` | `:0` | avfoundation audio index — run `meeting devices` to find yours |
| `MEETING_MAX_MIN` | `180` | auto-stop after N minutes (`0` = no cap) |
| `MEETING_MIN_FREE_MB` | `500` | low-disk warning before recording |
| `MEETING_PROMPT` | (unset) | override the glossary inline |

## The glossary (the differentiator)

whisper mis-hears domain terms. `~/.meeting/glossary.txt` is fed to whisper's `--prompt` so it
spells them right. In Claude Code the agent maintains this file from your editor memory, repo, and
past notes — so it learns *your* vocabulary over time. `meeting glossary` prints the current list.
**This file is personal and never belongs in a repository.**

## Transcription backends

The default is local **whisper.cpp** (offline, private). For higher accuracy you can switch
backends with `MEETING_ASR` and your own API key — `meeting` warns before any cloud upload:

```bash
MEETING_ASR=openai   OPENAI_API_KEY=...    meeting transcribe rec.wav   # OpenAI
MEETING_ASR=deepgram DEEPGRAM_API_KEY=...  meeting transcribe rec.wav   # Deepgram (+ diarization)
MEETING_ASR=faster-whisper                 meeting transcribe rec.wav   # local, no key
```

Built-in: `whisper` (default), `faster-whisper` (local), `openai`, `deepgram`. Adding a provider is
a single script in [`backends/`](backends/) — see [backends/README.md](backends/README.md).
Best-for-Chinese providers (讯飞 / 阿里) are scaffolded there as wanted contributions.

## Privacy & consent

- Recording + transcription run **entirely on your machine**; nothing is uploaded. Only
  `meeting setup` (model download) and the Claude Code summary step use the network.
- All data lives in `$MEETING_HOME` (default `~/.meeting`) and is **never committed** to this repo.
- **Recording people may require their consent.** Follow the laws and policies that apply to you.

## Troubleshooting

- **Empty recording / "录音没起来"** → grant your terminal Microphone permission
  (System Settings ▸ Privacy & Security ▸ Microphone), then retry.
- **Wrong mic** → `meeting devices`, then `export MEETING_AUDIO_INPUT=:N`.
- **`/meeting` not found in Claude Code** → restart Claude Code (skills load at session start).
- **A recording got cut off by a crash** → `meeting recover`.

## Limitations

- **macOS / Apple Silicon only** right now (avfoundation capture; whisper.cpp Metal).
- **No speaker diarization** yet — multi-person transcripts aren't split by speaker.
- **Far-field multi-speaker accuracy** is much lower than a single close mic.
- Capturing the *other side* of a Zoom call needs a virtual audio device (BlackHole) — see [docs/zoom-capture.md](docs/zoom-capture.md).

## Roadmap

- [ ] Codex adapter (`skills/codex/`) — same core, second ecosystem
- [ ] Speaker diarization (whisper.cpp `tinydiarize` / pyannote)
- [ ] System-audio capture (BlackHole / ScreenCaptureKit) for the Zoom other-side
- [ ] WhisperKit backend (faster on Apple Silicon)
- [ ] Live partial transcription while recording

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). TL;DR: bash + `set -euo pipefail`, passes `shellcheck`,
macOS-first, and **never commit runtime data**.

## License

MIT © pattypoem — see [LICENSE](LICENSE).
