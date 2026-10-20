# rootvscode — KVM-only Fly.io management server

Fly.io runs the authenticated browser IDE. VM execution is **KVM only**: either via a truly accessible local `/dev/kvm` or on a separate KVM-capable Linux host with SSH/libvirt. **No TCG, no emulation fallback.**

Fly.io has publicly stated that nested virtualization is unsupported on its Firecracker Machines. Creating `/dev/kvm` with `mknod` does **not** expose CPU virtualization extensions. A remote KVM host is therefore necessary when local KVM is unavailable.

## Runtime behavior

- `KVM_MODE=auto` (default): test local KVM API version and `KVM_CREATE_VM`. If that fails, try a configured remote libvirt KVM host. Otherwise, VM operations fail closed.
- `KVM_MODE=local`: only local hardware KVM. Command: `kvmctl run -m 2048 -drive file=/data/workspace/disk.qcow2,format=qcow2` (requires your guest disk image). The command enforces `-accel kvm`.
- `KVM_MODE=remote`: use a **different** Linux KVM host over SSH. Commands: `kvmctl check`, `kvmctl list`, `kvmctl define ./guest.xml`, `kvmctl start GUEST`, `kvmctl status GUEST`, `kvmctl shutdown GUEST`.
- VM domain definitions must have `<domain type='kvm'>`. Non-KVM configurations are rejected before starting.

**Compute location:** remote mode runs the guest CPU, RAM and disks on the external KVM server; Fly.io only hosts the IDE/control plane. If guest CPU must run on Fly.io, remote mode does not meet that requirement.

## First-time Fly.io setup

Existing volumes should be backed up before altering mounts. Check region and volume names with `fly volumes list -a rootvscode` before deployment.

Create or reuse the `code_data` volume in the `nrt` region, and use Fly secrets for the IDE password. For example:

```bash
PASSWORD="$(openssl rand -base64 32)"
printf 'Store this password securely: %s\n' "$PASSWORD"
fly secrets set -a rootvscode PASSWORD="$PASSWORD"
fly deploy -a rootvscode
```

Do **not** commit secrets to GitHub or `fly.toml`. `HASHED_PASSWORD` is also supported. Without either password, the container will refuse to start to avoid exposing root code-server without authentication.

The editor workspace, extensions, and data are stored under `/data`, which is the persistent volume mount. Check `kvmctl check` inside the editor terminal.

## Provision a remote genuine KVM host

1. Obtain a **separate physical Linux server**, or a VM from a provider that **explicitly permits nested virtualization**, where `/dev/kvm` actually works.
2. On Debian/Ubuntu install `qemu-kvm`, `libvirt-daemon-system`, `libvirt-clients`, `netcat-openbsd`, and `openssh-server`; enable SSH and libvirt.
3. Check `ls -l /dev/kvm` and `sudo virsh -c qemu:///system capabilities`. Capabilities must contain a KVM domain. Create a `<domain type='kvm'>` VM and make sure it can start *on the remote host*.
4. Create a dedicated SSH keypair and authorize its **public** key for a user with permission to manage libvirt on that host. Pin the remote host SSH key in a previously **verified** `known_hosts` file. `ssh-keyscan` alone does not authenticate the host.
5. Set these three Fly secrets using files stored **only on your trusted computer**:

```bash
fly secrets set -a rootvscode \
  KVM_REMOTE_URI='qemu+ssh://YOUR_USER@YOUR_KVM_HOST/system' \
  KVM_SSH_PRIVATE_KEY="$(cat ./kvm_ed25519)" \
  KVM_SSH_KNOWN_HOSTS="$(cat ./verified_known_hosts)"
```

The entrypoint configures SSH with `StrictHostKeyChecking yes`, noninteractive key authentication, and pinned known_hosts. URI query arguments that could bypass host-key checking are not accepted.

Test from the code-server terminal:

```bash
KVM_MODE=remote kvmctl check
KVM_MODE=remote kvmctl list
KVM_MODE=remote kvmctl start YOUR_EXISTING_KVM_DOMAIN
KVM_MODE=remote kvmctl status YOUR_EXISTING_KVM_DOMAIN
```

Guest disk images referenced in libvirt XML must be present **on the remote KVM host**. `kvmctl define` does not upload disks or install a guest OS.

## Error diagnosis

- `LOCAL_KVM_UNAVAILABLE`: missing/denied `/dev/kvm`, wrong KVM API or failed `KVM_CREATE_VM` ioctl.
- `no local KVM and no remote KVM host configured`: no real KVM available; configure a KVM-capable host.
- `remote host does not advertise a KVM domain`: remote libvirt does not expose KVM; fix host support rather than using TCG.
- SSH errors: verify private key, remote `authorized_keys`, host fingerprint, remote libvirt permissions, libvirt daemon and netcat.
- HTTP 502: check Fly logs; code-server requires `PASSWORD` or `HASHED_PASSWORD` at startup.

## Tests

```bash
python3 -m unittest discover -s tests -v
bash tests/test_kvmctl.sh
bash -n entrypoint.sh setup_kvm_ssh.sh kvmctl
```

Static tests check XML validation and fail-closed behavior; they do **not** prove KVM is exposed on Fly.io. End-to-end success means a real `type='kvm'` domain starts successfully on a KVM-capable host.

References: [Fly.io nested virtualization statement](https://community.fly.io/t/nested-virtualization-on-fly-io/11778), [libvirt connection URIs](https://www.libvirt.org/uri.html), [libvirt remote support](https://www.libvirt.org/remote.html).
