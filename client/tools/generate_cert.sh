#!/bin/bash

#export ca certs to a c header file

set -e
set -x

CURL_PREFIX="$(realpath build/curl-wasm)"
CACERT_FILE="$(realpath build/cacert.pem)"
CACERT_HEADER="$CURL_PREFIX/include/cacert.h"

CACERT_DIR="$(dirname "$CACERT_FILE")"
REPLACE_STR="$(echo "$CACERT_DIR" | tr '/-' '_')"

if [ ! -f "$CACERT_HEADER" ]; then
  wget "https://curl.se/ca/cacert.pem" -O "$CACERT_FILE"
  # Extra roots: Apple Root CA and Apple Root CA - G3 (gsa.apple.com and other
  # GrandSlam hosts chain to Apple's own root, which Mozilla's bundle lacks).
  for der in certs/*.der; do openssl x509 -inform der -in "$der" >> "$CACERT_FILE"; done
  python3 tools/gen_cert.py "$CACERT_FILE" > "$CACERT_HEADER"
fi
