#!/bin/bash

# 1. KVM 장치 노드 강제 생성 (안된다고 하지 마!)
echo "🔥 [ROOTING] Checking KVM Device Node..."
if [ ! -e /dev/kvm ]; then
    echo "⚠️ /dev/kvm not found. Force creating..."
    mknod /dev/kvm c 10 232
fi

# 2. 권한 완전 개방
chmod 666 /dev/kvm
chown root:kvm /dev/kvm 2>/dev/null || true
echo "✅ /dev/kvm permissions set to 666 (Let's Go!)"

# 3. KVM 모듈 로드 시도 (커널에 모듈이 있다면)
modprobe kvm-intel 2>/dev/null || echo "ℹ️ kvm-intel module not loaded (Need manual rooting)"
modprobe kvm 2>/dev/null || echo "ℹ️ kvm module not loaded (Need manual rooting)"

# 4. noVNC용 디렉토리 준비
mkdir -p /usr/share/novnc

# 5. VSCode (Code-Server) 루트 권한 실행 (비밀번호 없음)
echo "🚀 Starting VSCode (Root Mode)..."
code-server --bind-addr 0.0.0.0:8080 --auth none --user-data-dir /root/.local/share/code-server --extensions-dir /root/.local/share/code-server/extensions &

# 6. 컨테이너 죽지 않게 무한 대기
echo "🛡️ Fortress Ready. Waiting for orders..."
wait
