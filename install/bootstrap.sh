#!/usr/bin/env bash
#
# Vanta Panel bootstrap — the one-liner installer for a fresh VPS:
#
#   curl -fsSL https://get.vantapanel.com | sudo bash
#
# Downloads the latest release from update.json, verifies its sha256,
# extracts it, and hands over to the bundle's own bin/install.sh.
#
set -euo pipefail

say(){ printf '\033[1;32m==>\033[0m %s\n' "$*"; }
die(){ printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

BASE="https://get.vantapanel.com"

[ "$(id -u)" -eq 0 ] || die "run as root:  curl -fsSL https://get.vantapanel.com | sudo bash"
command -v apt-get >/dev/null 2>&1 \
  || die "Vanta Panel supports Ubuntu 22.04+ / Debian 12+ (apt-get was not found on this system)."

# Fresh images sometimes lack the tools the bootstrap itself needs.
need=""
for c in curl unzip; do command -v "$c" >/dev/null 2>&1 || need="$need $c"; done
if [ -n "$need" ]; then
  say "Installing bootstrap tools:$need"
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq || apt-get update
  apt-get install -y -qq ca-certificates $need >/dev/null
fi

say "Fetching release manifest…"
manifest="$(curl -fsSL --max-time 20 "$BASE/update.json")" || die "cannot reach $BASE/update.json — check this server's internet access"
url="$(printf '%s' "$manifest"  | sed -n 's/.*"url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'     | head -1)"
sha="$(printf '%s' "$manifest"  | sed -n 's/.*"sha256"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'  | head -1)"
ver="$(printf '%s' "$manifest"  | sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
[ -n "$url" ] && [ -n "$sha" ] || die "release manifest is malformed — please report this at https://vantapanel.com/contact"

work="$(mktemp -d /tmp/vantapanel-install.XXXXXX)"
cleanup(){ rm -rf "$work"; }
trap cleanup EXIT

say "Downloading Vanta Panel v${ver:-latest}…"
curl -fSL --max-time 300 --retry 2 -o "$work/vantapanel.zip" "$url" || die "download failed: $url"
printf '%s  %s\n' "$sha" "$work/vantapanel.zip" | sha256sum -c - >/dev/null 2>&1 \
  || die "checksum mismatch — the download was corrupted; please run the command again"

say "Extracting…"
unzip -q "$work/vantapanel.zip" -d "$work"
inst="$(find "$work" -maxdepth 3 -type f -path '*/bin/install.sh' | head -1)"
[ -n "$inst" ] || die "bundle is missing bin/install.sh — please report this at https://vantapanel.com/contact"
chmod +x "$inst"

if [ "${VP_BOOTSTRAP_ONLY:-0}" = "1" ]; then
  say "Bootstrap OK (v${ver:-?}) — stopping before install as requested (VP_BOOTSTRAP_ONLY=1)."
  exit 0
fi

say "Handing over to the Vanta Panel installer…"
trap - EXIT   # keep the extracted bundle; the installer copies it into place
exec bash "$inst"
