# Recording a Zoom call (all participants) — macOS

`meeting` records an audio *input*. In a Zoom call where you're muted, the other participants'
voices come out of your **speakers** (system *output*), so you need to route that output back
into an input. The standard, fully-local way is a free virtual audio device — **nothing leaves
your machine**.

> Recording other people may require their consent — follow your local laws and org policy.

## 1. Install BlackHole (virtual audio device)
```bash
brew install --cask blackhole-2ch     # needs your admin password
```

## 2. Hear Zoom *and* capture it — a Multi-Output Device
Open **Audio MIDI Setup** (⌘-Space → "Audio MIDI Setup"):
1. `+` (bottom-left) → **Create Multi-Output Device**.
2. Check both **your headphones/speakers** and **BlackHole 2ch**.
3. Set your headphones as **Primary** and enable **Drift Correction** on BlackHole.
4. In **Zoom ▸ Settings ▸ Audio ▸ Speaker**, choose this **Multi-Output Device**.
   → you still hear the call, and a copy is sent to BlackHole.

If you only ever need the *others'* audio, you can stop here and record BlackHole directly.

## 3. Also capture your own voice (when you unmute) — an Aggregate Device
1. In Audio MIDI Setup, `+` → **Create Aggregate Device**.
2. Check **BlackHole 2ch** + **your microphone** (e.g. "MacBook Pro Microphone").
3. This combined device is what `meeting` will record.

## 4. Point `meeting` at it
```bash
meeting devices                  # find the index of your Aggregate (or BlackHole) device
export MEETING_AUDIO_INPUT=:N    # N = that index (add to ~/.zshrc to persist)
meeting rec                      # records everyone (+ you), locally, with the live meter
```

## 5. Who said what (names)
A local recording gives you the full transcript but not speaker names. For names, lean on Zoom:
- **If you host:** Zoom gives you the recording + a name-labeled transcript/summary directly.
- **If you don't host:** turn on Zoom's live transcript and **save it before the meeting ends**
  (or enable auto-save in Zoom settings) — it already has names. Your local `meeting` recording
  is the always-available backup. Local speaker diarization is on the roadmap.

## Notes
- Switch Zoom's Speaker back to your normal output when you're done.
- A Multi-Output device controls volume from its primary sub-device.
- Modern alternative (no virtual device): macOS 13+ ScreenCaptureKit / 14.4+ Core Audio taps can
  capture an app's audio directly — planned, see the roadmap.
