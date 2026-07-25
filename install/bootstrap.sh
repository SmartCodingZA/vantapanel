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

# Ed25519 public key for release signatures. The private half never leaves the
# Vanta Panel release box. If this value is ever changed by someone other than
# Vanta Panel, signature verification below will FAIL rather than pass silently.
VP_RELEASE_PUBKEY="2g950+0wsBM3kjfr437q80GCYqM38BKvCpP6beZ6eRk="

[ "$(id -u)" -eq 0 ] || die "run as root:  curl -fsSL https://get.vantapanel.com | sudo bash"
command -v apt-get >/dev/null 2>&1 \
  || die "Vanta Panel supports Ubuntu 22.04+ / Debian 12+ (apt-get was not found on this system)."

# Fresh images sometimes lack the tools the bootstrap itself needs.
need=""
for c in curl unzip openssl; do command -v "$c" >/dev/null 2>&1 || need="$need $c"; done
if [ -n "$need" ]; then
  say "Installing bootstrap tools:$need"
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq || apt-get update
  apt-get install -y -qq ca-certificates $need >/dev/null
fi
# openssl and xxd are REQUIRED, not optional: without them the release signature
# below cannot be checked, and this script refuses to install unverified code.
for c in curl unzip openssl; do
  command -v "$c" >/dev/null 2>&1 \
    || die "required tool '$c' could not be installed — check this server's apt sources and try again"
done

say "Fetching release manifest…"
manifest="$(curl -fsSL --max-time 20 "$BASE/update.json")" || die "cannot reach $BASE/update.json — check this server's internet access"
url="$(printf '%s' "$manifest"  | sed -n 's/.*"url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'     | head -1)"
sha="$(printf '%s' "$manifest"  | sed -n 's/.*"sha256"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'  | head -1)"
ver="$(printf '%s' "$manifest"  | sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
sig="$(printf '%s' "$manifest"  | sed -n 's/.*"sig"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'      | head -1)"
[ -n "$url" ] && [ -n "$sha" ] || die "release manifest is malformed — please report this at https://vantapanel.com/contact"

work="$(mktemp -d /tmp/vantapanel-install.XXXXXX)"
cleanup(){ rm -rf "$work"; }
trap cleanup EXIT

say "Downloading Vanta Panel v${ver:-latest}…"
curl -fSL --max-time 300 --retry 2 -o "$work/vantapanel.zip" "$url" || die "download failed: $url"
printf '%s  %s\n' "$sha" "$work/vantapanel.zip" | sha256sum -c - >/dev/null 2>&1 \
  || die "checksum mismatch — the download was corrupted; please run the command again"

# ---- release signature (Ed25519) -------------------------------------------
# The sha256 above only proves the download matches what the SERVER SAID. It is
# not an integrity guarantee: whoever can serve you a modified vantapanel.zip
# can serve a matching sha256 in the same manifest. So we additionally verify a
# detached Ed25519 signature over "version|url|sha256" against a public key
# PINNED IN THIS SCRIPT. The matching private key never leaves the release box,
# so a tampered or substituted release cannot be signed — the install aborts.
#
# This same key and check are used by the panel's own auto-updater. You can
# audit this script at https://github.com/SmartCodingZA/vantapanel
say "Verifying release signature…"
[ -n "${sig:-}" ] || die "release manifest carries no signature — refusing to install (report this at https://vantapanel.com/contact)"

# An Ed25519 SubjectPublicKeyInfo is a fixed 12-byte DER prefix followed by the
# raw 32-byte key. 12 is divisible by 3, so in base64 the prefix maps to exactly
# 16 characters with no padding interaction — the PEM body is therefore a plain
# string concatenation. No xxd, no od, no base64 round-trip: nothing to install
# beyond openssl, which matters on minimal cloud images.
{
  echo "-----BEGIN PUBLIC KEY-----"
  echo "MCowBQYDK2VwAyEA${VP_RELEASE_PUBKEY}"
  echo "-----END PUBLIC KEY-----"
} > "$work/pub.pem"
openssl pkey -pubin -in "$work/pub.pem" -noout 2>/dev/null \
  || die "could not load the pinned release key (needs OpenSSL 3.x, present on Ubuntu 22.04+/Debian 12+) — please report this"

printf '%s|%s|%s' "$ver" "$url" "$sha" > "$work/signed.txt"
printf '%s' "$sig" | base64 -d > "$work/release.sig" 2>/dev/null \
  || die "release signature is not valid base64 — refusing to install"
[ "$(wc -c < "$work/release.sig")" -eq 64 ] || die "release signature has the wrong length — refusing to install"

openssl pkeyutl -verify -pubin -inkey "$work/pub.pem" -rawin \
    -in "$work/signed.txt" -sigfile "$work/release.sig" >/dev/null 2>&1 \
  || die "RELEASE SIGNATURE IS INVALID — this download was NOT published by Vanta Panel. Installation aborted. Please report this at https://vantapanel.com/contact"
say "Signature OK — authentic Vanta Panel release."

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
