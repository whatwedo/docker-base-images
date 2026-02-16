#!/bin/sh
set -e

if [ $# -ne 3 ]; then
    echo "usage: import-apt-key.sh <url> <expected-fingerprint> <keyring-path>" >&2
    exit 1
fi

URL="$1"
EXPECTED_FPR="$2"
KEYRING="$3"
TMP_DIR="$(mktemp -d)"
TMP_KEY="$TMP_DIR/signing-key"
GNUPGHOME="$TMP_DIR/gnupg"
KEYRING_TMP=""

cleanup() {
    rm -rf "$TMP_DIR"
    if [ -n "$KEYRING_TMP" ]; then
        rm -f "$KEYRING_TMP"
    fi
}
trap cleanup 0
trap 'exit 1' HUP INT TERM

case "$EXPECTED_FPR" in
    ''|*[!0-9A-Fa-f]*)
        echo "ERROR: expected fingerprint must be a hexadecimal value" >&2
        exit 1
        ;;
esac

EXPECTED_FPR="$(printf '%s' "$EXPECTED_FPR" | tr '[:lower:]' '[:upper:]')"
mkdir -m 0700 "$GNUPGHOME"

curl -fsSL "$URL" -o "$TMP_KEY"

PRIMARY_FPRS="$(
    gpg --batch --homedir "$GNUPGHOME" --show-keys --with-colons "$TMP_KEY" |
        awk -F: '
            $1 == "pub" { primary = 1; next }
            primary && $1 == "fpr" { print toupper($10); primary = 0; next }
            $1 == "sub" { primary = 0 }
        '
)"
PRIMARY_COUNT="$(printf '%s\n' "$PRIMARY_FPRS" | awk 'NF { count++ } END { print count + 0 }')"

if [ "$PRIMARY_COUNT" -ne 1 ]; then
    echo "ERROR: signing key bundle from $URL must contain exactly one primary key" >&2
    echo "       found $PRIMARY_COUNT primary keys" >&2
    exit 1
fi

ACTUAL_FPR="$PRIMARY_FPRS"
if [ "$ACTUAL_FPR" != "$EXPECTED_FPR" ]; then
    echo "ERROR: unexpected signing key for $URL" >&2
    echo "       expected $EXPECTED_FPR" >&2
    echo "       got      $ACTUAL_FPR" >&2
    exit 1
fi

mkdir -p "$(dirname "$KEYRING")"
KEYRING_TMP="$(mktemp "${KEYRING}.tmp.XXXXXX")"
gpg --batch --homedir "$GNUPGHOME" \
    --import-options import-minimal,import-export \
    --import "$TMP_KEY" > "$KEYRING_TMP"

if [ ! -s "$KEYRING_TMP" ]; then
    echo "ERROR: failed to export signing key $EXPECTED_FPR" >&2
    exit 1
fi

chmod 0644 "$KEYRING_TMP"
mv -f "$KEYRING_TMP" "$KEYRING"
KEYRING_TMP=""
