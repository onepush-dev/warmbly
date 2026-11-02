#!/bin/sh
# Runs as root to prepare the Railway volume, then drops every process to uid 1000.
set -eu
PORT="${PORT:-8080}"
export API_HOST="${API_HOST:-[::]:${PORT}}"
mkdir -p /data/blobs/geo /data/state
chown -R warmbly:warmbly /data

# KMS_LOCAL_MASTER_KEY must be base64 of 32 bytes. Railway can only generate
# hex/alnum secrets, so a 64-char hex value is converted here (same 32 bytes).
if printf '%s' "${KMS_LOCAL_MASTER_KEY:-}" | grep -Eq '^[0-9a-fA-F]{64}$'; then
  KMS_LOCAL_MASTER_KEY="$(printf '%s' "$KMS_LOCAL_MASTER_KEY" | xxd -r -p | base64 | tr -d '\n')"
  export KMS_LOCAL_MASTER_KEY
fi

# First owner: hash the generated WARMBLY_ADMIN_PASSWORD (argon2id) so no
# plaintext password reaches the app. Only used while the users table is empty.
if [ -n "${WARMBLY_ADMIN_PASSWORD:-}" ] && [ -z "${WARMBLY_BOOTSTRAP_PASSWORD_HASH:-}" ] && [ -z "${WARMBLY_BOOTSTRAP_PASSWORD:-}" ]; then
  if H="$(printf '%s' "$WARMBLY_ADMIN_PASSWORD" | warmblyctl hash-password 2>/dev/null)"; then
    export WARMBLY_BOOTSTRAP_PASSWORD_HASH="$H"
  else
    echo "[warmbly] could not hash WARMBLY_ADMIN_PASSWORD; use 'warmblyctl setup-link' to claim the instance" >&2
  fi
fi
unset WARMBLY_ADMIN_PASSWORD

echo "[warmbly] starting backend on ${API_HOST}"
su-exec warmbly /app/backend & B=$!
trap 'kill -TERM $B ${W:-} ${C:-} 2>/dev/null; wait; exit 0' TERM INT
i=0
until wget -q -O /dev/null "http://127.0.0.1:${PORT}/health"; do
  kill -0 $B 2>/dev/null || { echo "[warmbly] backend exited during startup" >&2; exit 1; }
  i=$((i+1)); [ $i -gt 600 ] && { echo "[warmbly] backend not healthy after 10 min" >&2; kill -TERM $B; exit 1; }
  sleep 1
done
echo "[warmbly] backend healthy; starting worker + consumer"
env -u PRIMARY_DB ENCRYPTED_KEYS_PROVIDER=http ENCRYPTED_KEYS_BACKEND_URL="http://127.0.0.1:${PORT}" \
  ENCRYPTED_KEYS_WORKER_TOKEN="${NODE_BROKER_TOKEN:-${INTERNAL_API_TOKEN:-}}" \
  su-exec warmbly /app/worker & W=$!
su-exec warmbly /app/consumer & C=$!
while kill -0 $B 2>/dev/null && kill -0 $W 2>/dev/null && kill -0 $C 2>/dev/null; do sleep 5; done
echo "[warmbly] a process exited; stopping so Railway restarts the container" >&2
kill -TERM $B $W $C 2>/dev/null || true
wait || true
exit 1
