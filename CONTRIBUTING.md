# Contributing to meeting-agent

Thanks for your interest! This is a small, deliberately-scoped tool — contributions that keep it
simple are the most welcome.

## Architecture (two layers)

- **Core CLI** (`bin/meeting`) — agent-agnostic, pure bash. Does *only* what an agent can't:
  record (ffmpeg) and transcribe (whisper.cpp).
- **Agent adapters** (`skills/`) — thin wrappers that drive the CLI and do the smart part
  (summary / extraction / filing). `skills/claude/` is the Claude Code skill; `skills/codex/` is planned.

Rule of thumb: the CLI stays dumb and deterministic; anything "smart" belongs in the agent layer.
The final stdout of `stop`/`transcribe` must remain the transcript path (agents parse it) — send
everything else to stderr.

## Dev setup

```bash
git clone https://github.com/pattypoem/meeting-agent
cd meeting-agent && ./install.sh && meeting setup
```

## Before opening a PR

- Shell is bash with `set -euo pipefail`.
- Run **shellcheck** locally (CI runs the same): `shellcheck -S error bin/meeting install.sh`
- Keep it **macOS / Apple Silicon-first**. Cross-platform support is welcome but must not break the mac path.
- **Never commit runtime data.** Recordings, transcripts, notes, and `glossary.txt` live in
  `$MEETING_HOME` (`~/.meeting`) and may contain private/personal information. They are outside the
  repo by design — keep it that way.

## Recording the demo gif

```bash
# with asciinema + agg (or any screen recorder):
asciinema rec demo.cast      # run `meeting rec`, say a few words, Ctrl-C
agg demo.cast docs/demo.gif
```

## Scope / non-goals

Not trying to beat Granola / MacWhisper on UX. The bet is "agent-native + local + context-aware."
PRs that add a GUI are out of scope.
