#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

if [[ -z "${PASSWORD:-}" && -z "${HASHED_PASSWORD:-}" ]]; then
  echo >&2 "ERROR: Set PASSWORD or HASHED_PASSWORD through Fly secrets before starting code-server."
  exit 1
fi

mkdir -p /data/workspace /data/code-server/user-data /data/code-server/extensions

if [[ -n "${KVM_REMOTE_URI:-}" ]]; then
  /usr/local/bin/setup_kvm_ssh.sh
fi

if /usr/local/bin/kvmctl check; then
  echo "KVM backend verified."
else
  echo >&2 "WARNING: No verified KVM backend. Code-server will start; VM commands fail closed."
  echo >&2 "Configure an actual KVM-capable host or use a platform that exposes /dev/kvm."
fi

# PID 1 belongs to code-server; a failed web service exits the container.
exec code-server \
  --bind-addr 0.0.0.0:8080 \
  --auth password \
  --user-data-dir /data/code-server/user-data \
  --extensions-dir /data/code-server/extensions \
  /data/workspace
