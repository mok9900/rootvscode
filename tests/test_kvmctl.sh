#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."
# Invalid modes and absent KVM must never fall back to TCG.
if KVM_MODE=invalid bash ./kvmctl check > /dev/null 2>&1; then
  echo 'FAIL: accepted invalid mode' >&2; exit 1
fi
if KVM_MODE=remote KVM_REMOTE_URI='' bash ./kvmctl check > /dev/null 2>&1; then
  echo 'FAIL: remote mode unexpectedly worked without a host' >&2; exit 1
fi
if grep -qi -- 'kvm:tcg\|accel=tcg\|-accel tcg' kvmctl; then
  echo 'FAIL: found TCG fallback in kvmctl' >&2; exit 1
fi
echo 'PASS: KVM-only fail-closed checks'
