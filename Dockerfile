# 베이스 이미지: 데비안 12 (가장 순정 상태의 강력함)
FROM debian:12

# 1. 환경 변수: 무조건 루트, 무조건 가속 시도, 로케일 설정
ENV DEBIAN_FRONTEND=noninteractive \
    USER=root \
    HOME=/root \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    # KVM 가속 강제 환경 변수
    QEMU_AUDIO_DRV=none \
    ACCEL=kvm:tcg \
    CPU_MODEL=host 

# 2. 패키지 보급: 커널 루팅 도구 + 가상화 엔진 + VSCode 구동용
RUN apt-get update && apt-get install -y \
    curl wget git vim nano unzip \
    build-essential \
    linux-headers-generic || true \
    libncurses-dev bison flex libssl-dev libelf-dev \
    qemu-system-x86 qemu-utils bridge-utils \
    psmisc procps net-tools iproute2 \
    ca-certificates gnupg \
    locales \
    python3 python3-pip \
    websockify novnc \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Code-Server (VSCode) 설치 - 루트 권한으로 실행
RUN curl -fsSL https://code-server.dev/install.sh | sh

# 4. KVM 장치 노드 생성 스크립트 및 시작 스크립트 배치
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 5. 작업 디렉토리 설정
WORKDIR /root

# 6. 포트 개방 (8080: VSCode, 8006: NoVNC, 5900: VNC원본)
EXPOSE 8080 8006 5900

# 7. 실행
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
