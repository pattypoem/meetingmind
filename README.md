# meeting-agent

> Agent-native meeting notes. No app, no UI — one command inside Claude Code / Codex.
> Records locally, transcribes locally (whisper.cpp), and lets your coding agent do
> the summary, action-item extraction, and routing.

## Why this instead of another meeting app

The "local whisper + LLM summary" space is crowded (Granola, Hyprnote, Meetily,
MacWhisper…). This project does **not** compete on UX. Its bet is positioning:

- **Lives where you already work** — a terminal agent (Claude Code / Codex), not a separate app.
- **Agentic, not a notes dump** — you can *ask follow-ups* about the transcript and the
  agent can *take actions* (write to Notion via MCP, open an issue, link decisions to code).
- **No UI to build, no extra LLM key** — the summarization is done by the host agent itself.

## Architecture (two layers)

```
┌─ agent-agnostic core ──────────────┐     ┌─ thin per-agent adapter ─────────┐
│  bin/meeting                       │     │  skills/claude/meeting/SKILL.md  │  → /meeting in Claude Code
│   • record  (ffmpeg)               │ ◀── │  skills/codex/...  (phase 2)     │  → command in Codex
│   • transcribe (whisper.cpp)       │     │  the host agent reads the        │
│   • emits transcript path on stdout│     │  transcript & does summary/route │
└────────────────────────────────────┘     └──────────────────────────────────┘
```

The core is just record + transcribe — the only things an agent can't do itself.
Everything intelligent is the agent's job, which is what keeps the surface area tiny
and the same core reusable across agent ecosystems.

## Requirements

- macOS on Apple Silicon (v0 target — scoped deliberately; cross-OS later)
- `ffmpeg` (`brew install ffmpeg`)
- `whisper.cpp` + a model — installed by `meeting setup`
- Optional: **BlackHole** (virtual audio) to capture the *other side* of a Zoom call.
  Mic-only (in-person, or your own voice) needs nothing extra.

## Install

```bash
./install.sh          # symlinks bin/meeting to ~/.local/bin, installs the Claude Code skill
meeting setup         # brew install whisper-cpp + download model (~1.6GB)
```

## Use

In Claude Code:

```
/meeting start        # starts recording in the background
…meeting happens…
/meeting stop         # stops, transcribes locally, then summarizes + extracts action items
```

Or process an existing file:

```
/meeting ~/Downloads/some-recording.m4a
/meeting ~/Downloads/existing-transcript.txt
```

CLI directly (no agent):

```bash
meeting start
meeting stop          # prints the transcript .txt path
meeting devices       # list audio input indices (set MEETING_AUDIO_INPUT=:n)
```

## Config (env vars)

| var | default | meaning |
|-----|---------|---------|
| `MEETING_MODEL` | `~/.meeting/models/ggml-large-v3-turbo.bin` | whisper model (use `ggml-large-v3` for max accuracy, `ggml-medium` for smaller) |
| `MEETING_LANG`  | `auto` | `zh` / `en` / `auto` |
| `MEETING_AUDIO_INPUT` | `:0` | avfoundation audio index (`meeting devices` to list) |
| `MEETING_HOME`  | `~/.meeting` | recordings / models / notes live here |

## Roadmap

- [ ] Codex adapter (`skills/codex/`) — same core, second ecosystem
- [ ] BlackHole auto-setup + Multi-Output device for Zoom system-audio capture
- [ ] Speaker diarization (whisper.cpp `--tinydiarize` / pyannote)
- [ ] Live partial transcription while recording
- [ ] Optional routing presets (Notion / Linear / file)
- [ ] Recording-consent guardrail / banner
