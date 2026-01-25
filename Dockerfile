FROM debian:12

# 1. 환경 설정
ENV DEBIAN_FRONTEND=noninteractive \
    USER=root \
    HOME=/root \
    LANG=en_US.UTF-8

# 2. 시스템 기초 및 kmod(커널 조작), 네트워크 도구 설치
RUN apt-get update && apt-get install -y --no-install-recommends \
    kmod \
    curl \
    wget \
    git \
    vim \
    nano \
    unzip \
    ca-certificates \
    gnupg \
    locales \
    procps \
    psmisc \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

# 3. QEMU 풀 패키지 및 가상화 빌드 도구 (지휘관님이 말씀하신 qemx 등 핵심 포함)
RUN apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    qemu-system-common \
    qemu-system-data \
    bridge-utils \
    libvirt-clients \
    libvirt-daemon-system \
    build-essential \
    linux-headers-amd64 \
    libncurses-dev \
    bison \
    flex \
    libssl-dev \
    libelf-dev

# 4. 언어 및 런타임 (Python, Docker CLI 등)
# 컨테이너 안에서 또 다른 도커 명령을 내릴 수 있게 docker-ce-cli를 준비합니다.
RUN apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    iptables \
    && curl -fsSL https://get.docker.com -o get-docker.sh \
    && sh get-docker.sh --docker-extra-args "--skip-service-start"

# 5. VSCode (Code-Server) 및 noVNC 설정
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN apt-get install -y novnc websockify

# 6. 마무리 세팅
WORKDIR /root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080 8006 5900

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
