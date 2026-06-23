#!/usr/bin/env bash
# Template for a meeting-agent ASR backend. Copy to <name>.sh, then select with MEETING_ASR=<name>.
#
# Contract:
#   - invoked as:  <name>.sh <audio_path> <out_base> <lang>
#   - env available: $MEETING_PROMPT_TEXT (glossary; may be empty) + your provider's API key
#   - MUST write "<out_base>.txt" (plain transcript)
#   - SHOULD write "<out_base>.srt" (SubRip w/ timestamps; prefix lines "Speaker N: " if diarized)
#   - exit 0 on success, non-zero on failure
#
# Tip: parse provider JSON with python3 (always present), e.g.  curl ... | python3 -c '...' "$base"
set -euo pipefail
audio="$1"; base="$2"; lang="${3:-auto}"
: "${YOUR_PROVIDER_API_KEY:?set YOUR_PROVIDER_API_KEY}"

# 1) send "$audio" to your provider (pass $MEETING_PROMPT_TEXT as a glossary/hint if supported)
# 2) write "$base.txt"  (and ideally "$base.srt")

echo "backend template not implemented — see backends/README.md" >&2
exit 1
