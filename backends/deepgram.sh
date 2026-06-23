#!/usr/bin/env bash
# Deepgram backend (Nova-3) with diarization.  Needs: DEEPGRAM_API_KEY   (deps: curl, python3)
# Produces .txt and a .srt whose cues are prefixed "Speaker N:" (free diarization).
# Invoked as: deepgram.sh <audio> <out_base> <lang>
set -euo pipefail
audio="$1"; base="$2"; lang="${3:-auto}"
: "${DEEPGRAM_API_KEY:?set DEEPGRAM_API_KEY}"
model="${MEETING_DEEPGRAM_MODEL:-nova-3}"
url="https://api.deepgram.com/v1/listen?model=$model&smart_format=true&punctuate=true&diarize=true"
[ "$lang" != auto ] && url="$url&language=$lang"

curl -sS --fail -X POST "$url" \
  -H "Authorization: Token $DEEPGRAM_API_KEY" \
  -H "Content-Type: audio/wav" --data-binary "@$audio" \
| python3 -c '
import sys, json
base=sys.argv[1]; d=json.load(sys.stdin)
alt=d["results"]["channels"][0]["alternatives"][0]
open(base+".txt","w").write((alt.get("transcript","") or "").strip()+"\n")
def ts(x):
    h=int(x//3600); m=int(x%3600//60); s=x%60
    return "%02d:%02d:%02d,%03d"%(h,m,int(s),min(999,round((s-int(s))*1000)))
cues=[]; cur=None
for w in alt.get("words") or []:
    sp=w.get("speaker"); txt=w.get("punctuated_word") or w.get("word","")
    if cur and cur["sp"]==sp:
        cur["t"]+=" "+txt; cur["end"]=w["end"]
    else:
        if cur: cues.append(cur)
        cur={"sp":sp,"start":w["start"],"end":w["end"],"t":txt}
if cur: cues.append(cur)
with open(base+".srt","w") as f:
    for i,c in enumerate(cues,1):
        spk=("Speaker %s: "%c["sp"]) if c["sp"] is not None else ""
        f.write("%d\n%s --> %s\n%s%s\n\n"%(i,ts(c["start"]),ts(c["end"]),spk,c["t"].strip()))
' "$base"
