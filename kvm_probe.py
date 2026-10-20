#!/usr/bin/env python3
"""Verify that a Linux KVM device supports ioctls and creating a VM.

A filesystem node created by mknod is insufficient to prove KVM access.
"""
import fcntl
import os
import sys

KVM_GET_API_VERSION = 0xAE00
KVM_CREATE_VM = 0xAE01
EXPECTED_API_VERSION = 12


def main() -> int:
    path = "/dev/kvm"
    try:
        fd = os.open(path, os.O_RDWR | os.O_CLOEXEC)
    except OSError as exc:
        print(f"LOCAL_KVM_UNAVAILABLE: cannot open {path}: {exc}", file=sys.stderr)
        return 1

    try:
        version = fcntl.ioctl(fd, KVM_GET_API_VERSION, 0)
        if version != EXPECTED_API_VERSION:
            print(f"LOCAL_KVM_UNAVAILABLE: unexpected KVM API version {version}", file=sys.stderr)
            return 1
        vm_fd = fcntl.ioctl(fd, KVM_CREATE_VM, 0)
        try:
            print("LOCAL_KVM_READY: API version 12; KVM_CREATE_VM succeeded")
        finally:
            os.close(vm_fd)
        return 0
    except OSError as exc:
        print(f"LOCAL_KVM_UNAVAILABLE: KVM ioctl failed: {exc}", file=sys.stderr)
        return 1
    finally:
        os.close(fd)


if __name__ == "__main__":
    sys.exit(main())
