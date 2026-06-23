#!/usr/bin/env bash
# OpenAI transcription backend.  Needs: OPENAI_API_KEY   (deps: curl, python3)
# Default model whisper-1 → returns timestamps, so we get both .txt and .srt.
# Set MEETING_OPENAI_MODEL=gpt-4o-transcribe for higher accuracy (text only, no .srt).
# Invoked as: openai.sh <audio> <out_base> <lang>   (glossary via $MEETING_PROMPT_TEXT)
set -euo pipefail
audio="$1"; base="$2"; lang="${3:-auto}"
: "${OPENAI_API_KEY:?set OPENAI_API_KEY}"
model="${MEETING_OPENAI_MODEL:-whisper-1}"

args=(-sS --fail -X POST https://api.openai.com/v1/audio/transcriptions
  -H "Authorization: Bearer $OPENAI_API_KEY"
  -F "file=@$audio" -F "model=$model")
[ "$lang" != auto ] && args+=(-F "language=$lang")
[ -n "${MEETING_PROMPT_TEXT:-}" ] && args+=(-F "prompt=$MEETING_PROMPT_TEXT")

if [ "$model" = whisper-1 ]; then
  args+=(-F "response_format=verbose_json")
  curl "${args[@]}" | python3 -c '
import sys, json
base=sys.argv[1]; d=json.load(sys.stdin)
open(base+".txt","w").write((d.get("text","") or "").strip()+"\n")
def ts(x):
    h=int(x//3600); m=int(x%3600//60); s=x%60
    return "%02d:%02d:%02d,%03d"%(h,m,int(s),min(999,round((s-int(s))*1000)))
with open(base+".srt","w") as f:
    for i,seg in enumerate(d.get("segments") or [],1):
        f.write("%d\n%s --> %s\n%s\n\n"%(i,ts(seg["start"]),ts(seg["end"]),(seg.get("text") or "").strip()))
' "$base"
else
  args+=(-F "response_format=text")
  curl "${args[@]}" > "$base.txt"
fi
