#!/bin/bash
set -e

echo "🔥 [ROOTING] Bypassing Firecracker Jail with 128GB RAM Power..."

# 1. 128GB 램 활용을 위한 커널 파라미터 튜닝
# 램 부족으로 죽는 일 없도록 overcommit을 허용합니다.
echo 1 > /proc/sys/vm/overcommit_memory 2>/dev/null || true

# 2. KVM 강제 점유 스크립트 백그라운드 실행
/usr/local/bin/kvm-rooting.sh &

# 3. 오디오 서버 기동
pulseaudio --start --exit-idle-time=-1 --system=false 2>/dev/null || true

# 4. VSCode (Root Mode)
echo "🚀 Starting VSCode (Root Mode)..."
code-server --bind-addr 0.0.0.0:8080 --auth none --user-data-dir /root/.local/share/code-server --extensions-dir /root/.local/share/code-server/extensions &

echo "✅ 128GB Monster RAM & 16 Cores Ready."
wait
