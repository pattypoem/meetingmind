#!/usr/bin/env bash
# faster-whisper backend — LOCAL, no key (often faster than whisper.cpp on CPU/GPU).
# deps: python3 + `pip install faster-whisper`.  Model via MEETING_FW_MODEL (default large-v3;
# faster-whisper downloads its own models from HuggingFace, separate from whisper.cpp).
# Invoked as: faster-whisper.sh <audio> <out_base> <lang>
set -euo pipefail
audio="$1"; base="$2"; lang="${3:-auto}"
python3 -c '
import sys, os
from faster_whisper import WhisperModel
audio, base, lang, size = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
model = WhisperModel(size, device="auto", compute_type="auto")
segments, info = model.transcribe(
    audio, language=None if lang=="auto" else lang,
    initial_prompt=os.environ.get("MEETING_PROMPT_TEXT") or None)
def ts(x):
    h=int(x//3600); m=int(x%3600//60); s=x%60
    return "%02d:%02d:%02d,%03d"%(h,m,int(s),min(999,round((s-int(s))*1000)))
with open(base+".txt","w") as txt, open(base+".srt","w") as srt:
    for i,seg in enumerate(segments,1):
        t=seg.text.strip()
        txt.write(t+"\n")
        srt.write("%d\n%s --> %s\n%s\n\n"%(i,ts(seg.start),ts(seg.end),t))
' "$audio" "$base" "$lang" "${MEETING_FW_MODEL:-large-v3}"
