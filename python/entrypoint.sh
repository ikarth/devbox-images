#!/bin/bash
# devbox entrypoint: prepare the persistent home, then run sshd (as `dev`).
set -euo pipefail

STATE="$HOME/.devbox"
mkdir -p "$STATE" "$HOME/.ssh" "$HOME/.cache"
chmod 700 "$STATE" "$HOME/.ssh"

# Host keys: generated once, kept on the volume so the fingerprint is stable.
for t in ed25519 rsa; do
  key="$STATE/ssh_host_${t}_key"
  [ -f "$key" ] || ssh-keygen -q -t "$t" -N "" -f "$key"
done
chmod 600 "$STATE"/ssh_host_*_key

# Authorized keys come from the mounted ConfigMap (copied so sshd's
# StrictModes ownership/permission checks pass).
if [ -f /etc/devbox/authorized_keys ]; then
  install -m 600 /etc/devbox/authorized_keys "$STATE/authorized_keys"
else
  echo "WARNING: /etc/devbox/authorized_keys missing: nobody can log in" >&2
fi

# Friendly shell defaults on first start (never overwrite user edits).
[ -f "$HOME/.bashrc" ] || cp /etc/skel/.bashrc "$HOME/.bashrc"
[ -f "$HOME/.profile" ] || cp /etc/skel/.profile "$HOME/.profile"
if ! grep -q 'devbox: auto-activate venv' "$HOME/.bashrc"; then
  cat >> "$HOME/.bashrc" <<'EOF'
# devbox: auto-activate venv if one exists
[ -f "$HOME/venv/bin/activate" ] && . "$HOME/venv/bin/activate"
export HF_HOME="${HF_HOME:-$HOME/.cache/huggingface}"
EOF
fi

echo "devbox: sshd starting on :2222 (user $(id -un))"
exec /usr/sbin/sshd -D -e -f /etc/ssh/devbox_sshd_config
