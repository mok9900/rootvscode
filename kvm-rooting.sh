#!/bin/bash
# FLY 환경의 Firecracker가 KVM을 숨겨도 강제로 찾아내서 찢어버리는 스크립트

while true; do
    if [ ! -e /dev/kvm ]; then
        mknod /dev/kvm c 10 232
        chmod 666 /dev/kvm
    fi
    # 누군가 권한을 뺏어가도 1초마다 다시 뺏어옴
    chmod 666 /dev/kvm 2>/dev/null
    sleep 1
done
