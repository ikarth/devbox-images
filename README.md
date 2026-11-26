# devbox-images

Container images for SSH-reachable dev boxes on the home cluster
(manifests live in the private cluster repo).

## devbox-python

`ghcr.io/ikarth/devbox-python:<YYYYMMDD>-<sha>` (also `:latest`, but deploy a
dated tag).

- Debian (python:3.12-slim-trixie) + sshd, git, build tools, tmux, etc.
- Runs as unprivileged `dev` (uid 1000), no sudo. sshd on port 2222, key-only.
- `/home/dev` is meant to be a persistent volume: code, `~/venv`, the Hugging
  Face cache (`HF_HOME=~/.cache/huggingface`) and SSH host keys live there.
- Authorized keys are read from `/etc/devbox/authorized_keys` (mount a
  ConfigMap there).
- Python packages: `python -m venv ~/venv && ~/venv/bin/pip install ...`
  (auto-activated in new shells). CPU-only PyTorch:
  `pip install torch --index-url https://download.pytorch.org/whl/cpu`.
- System packages need an image change: edit `python/Dockerfile`.

Rebuilt on every change and weekly (security updates) by
`.github/workflows/devbox-python.yml`.
