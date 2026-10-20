FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/root \
    USER=root

RUN apt-get update && apt-get install -y --no-install-recommends \
      bash ca-certificates curl git openssh-client python3 \
      qemu-system-x86 qemu-utils libvirt-clients \
      vim nano procps \
    && rm -rf /var/lib/apt/lists/*

# code-server provides browser-based management; QEMU is KVM-only.
RUN curl -fsSL https://code-server.dev/install.sh | sh

COPY entrypoint.sh kvmctl kvm_probe.py verify_kvm_xml.py setup_kvm_ssh.sh /usr/local/bin/
RUN chmod 0755 /usr/local/bin/entrypoint.sh /usr/local/bin/kvmctl \
      /usr/local/bin/kvm_probe.py /usr/local/bin/verify_kvm_xml.py \
      /usr/local/bin/setup_kvm_ssh.sh \
    && mkdir -p /data/workspace /root/.ssh

WORKDIR /data/workspace
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
