#!/bin/sh
# Read-only checks for the verified WeType + BlackHole + Fn runtime.
set -eu

APP="/Applications/Google Remote Voice.app"
DRIVER="/Library/Audio/Plug-Ins/HAL/BlackHole2ch.driver"
APP_CONFIG="$HOME/Library/Application Support/GoogleRemoteVoice/config.json"
LOG="$HOME/Library/Logs/GoogleRemoteVoice/engine.log"
WETYPE="$HOME/Library/Application Support/WeType/mmkv/wetype.settings"
status=0

ok() { printf 'OK   %s\n' "$1"; }
miss() { printf 'MISS %s\n' "$1"; status=1; }

[ -d "$APP" ] && ok "Google Remote Voice.app" || miss "Google Remote Voice.app"
[ -d "$DRIVER" ] && ok "BlackHole2ch.driver" || miss "BlackHole2ch.driver"
if [ -d "$APP" ]; then
  if codesign --verify --deep --strict "$APP" >/dev/null 2>&1; then ok "app code signature"; else miss "app code signature"; fi
fi

if [ -f "$APP_CONFIG" ]; then
  python3 - "$APP_CONFIG" <<'PY' || status=1
import json, sys
cfg = json.load(open(sys.argv[1]))
v = cfg.get("voice", {})
checks = [
    (v.get("keycode") == 0x3F and not v.get("cmd"), "app voice key = bare Fn"),
    (cfg.get("voiceStartsMic") is True, "voice starts microphone"),
]
for value, label in checks:
    print(("OK   " if value else "MISS ") + label)
if not all(v for v, _ in checks):
    sys.exit(1)
PY
else
  miss "app config.json"
fi

assistant="$(defaults read com.apple.assistant.support 'Assistant Enabled' 2>/dev/null || echo 1)"
dictation="$(defaults read com.apple.assistant.support 'Dictation Enabled' 2>/dev/null || echo 1)"
if [ "$assistant" = "0" ] && [ "$dictation" = "0" ]; then ok "macOS dictation/voice control off"; else miss "macOS dictation/voice control should be off"; fi

if system_profiler SPAudioDataType 2>/dev/null | grep -q 'BlackHole 2ch'; then ok "BlackHole 2ch visible"; else miss "BlackHole 2ch not visible (logout/login may be needed)"; fi
audio="$(system_profiler SPAudioDataType 2>/dev/null || true)"
if printf '%s\n' "$audio" | grep -q 'Default Input Device: Yes'; then ok "a default input device exists"; else miss "no default input device; check manually"; fi
if printf '%s\n' "$audio" | grep -q 'Default Output Device: Yes'; then ok "a default output device exists"; else miss "no default output device; check manually"; fi

if [ -f "$LOG" ]; then
  if grep -q '语音键按下 → Fn' "$LOG"; then ok "Fn voice-key log evidence"; else miss "Fn voice-key log evidence"; fi
  if grep -Eq '[4-5][0-9]\.[0-9] 包/秒' "$LOG"; then ok "about 50 packets/sec log evidence"; else miss "about 50 packets/sec log evidence"; fi
else
  miss "engine.log"
fi

if [ -f "$WETYPE" ]; then
  python3 - "$WETYPE" <<'PY' || status=1
import sys
b = open(sys.argv[1], "rb").read()
checks = {
    "WeType mic = BlackHole 2ch": b"BlackHole2ch_UID" in b,
    "WeType PTT = Fn (keycode 63)": b"voicePTTShortcut_keyCodes" in b and bytes([63]) in b,
    "WeType voice hotkey enabled": b"voicePTTHotKey" in b,
}
for label, value in checks.items():
    print(("OK   " if value else "MISS ") + label)
if not all(checks.values()):
    sys.exit(1)
PY
else
  miss "WeType settings"
fi

if [ "$status" -eq 0 ]; then
  printf '\n只读检查通过；最终仍以真实中文上屏为准。\n'
else
  printf '\n部分只读检查未通过；请按 MISS 项人工核对。\n'
fi
exit "$status"
