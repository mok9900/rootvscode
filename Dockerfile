FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive \
    USER=root \
    HOME=/root \
    LANG=en_US.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    kmod curl wget git vim nano unzip ca-certificates gnupg locales procps psmisc \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# QEMU + Audio(ALSA/Pulse) + 가상화 라이브러리
RUN apt-get install -y --no-install-recommends \
    qemu-system-x86 qemu-utils qemu-system-common qemu-system-gui \
    libvirt-clients libvirt-daemon-system build-essential \
    linux-headers-amd64 libncurses-dev bison flex libssl-dev libelf-dev \
    pulseaudio alsa-utils libasound2-dev # 오디오 추가

# VSCode & noVNC
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN apt-get install -y novnc websockify

WORKDIR /root
# 해킹 스크립트 주입
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
# [신규] KVM 권한 강제 고정 스크립트
COPY kvm-rooting.sh /usr/local/bin/kvm-rooting.sh

RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/kvm-rooting.sh

EXPOSE 8080 8006 5900
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
