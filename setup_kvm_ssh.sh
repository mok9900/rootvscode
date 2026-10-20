#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

: "${KVM_REMOTE_URI:?Set a remote qemu+ssh://user@host/system URI}"
: "${KVM_SSH_PRIVATE_KEY:?Set the KVM_SSH_PRIVATE_KEY secret}"
: "${KVM_SSH_KNOWN_HOSTS:?Set the pinned KVM_SSH_KNOWN_HOSTS secret}"

# Deliberately reject URI query arguments that could disable host key checking.
host="$(python3 - <<'PY'
import os
import re
import sys
from urllib.parse import urlsplit
uri = os.environ["KVM_REMOTE_URI"]
parsed = urlsplit(uri)
if (parsed.scheme != "qemu+ssh" or parsed.path != "/system" or
        not parsed.hostname or not parsed.username or parsed.query or parsed.fragment or
        not re.fullmatch(r"[A-Za-z0-9.-]+", parsed.hostname)):
    sys.exit("ERROR: KVM_REMOTE_URI must be qemu+ssh://user@host/system, without a query or fragment")
print(parsed.hostname)
PY
)"

install -d -m 0700 /root/.ssh
printf '%s\n' "$KVM_SSH_PRIVATE_KEY" > /root/.ssh/id_kvm
printf '%s\n' "$KVM_SSH_KNOWN_HOSTS" > /root/.ssh/known_hosts
chmod 0600 /root/.ssh/id_kvm /root/.ssh/known_hosts
cat > /root/.ssh/config <<CONFIG
Host ${host}
    BatchMode yes
    StrictHostKeyChecking yes
    UserKnownHostsFile /root/.ssh/known_hosts
    IdentityFile /root/.ssh/id_kvm
    IdentitiesOnly yes
    ConnectTimeout 10
CONFIG
chmod 0600 /root/.ssh/config
