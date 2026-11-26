# devbox-python: SSH-reachable Python dev environment for the home cluster.
#
# - Runs entirely as the unprivileged user `dev` (uid/gid 1000), no sudo.
#   sshd runs as that user on port 2222 (key-only login, only `dev`).
# - /home/dev is expected to be a persistent volume: code, venvs, the
#   Hugging Face cache and SSH host keys live there. Python packages go in a
#   venv on that volume (`python -m venv ~/venv`), so adding libraries never
#   needs an image rebuild. System packages DO need a rebuild (add below).
# - Authorized keys are read from /etc/devbox/authorized_keys (mounted).
FROM docker.io/library/python:3.12-slim-trixie

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      openssh-server openssh-client \
      git git-lfs ca-certificates curl wget \
      build-essential pkg-config \
      tini procps less vim-tiny nano tmux htop rsync unzip jq \
 && rm -rf /var/lib/apt/lists/* \
 && rm -f /etc/ssh/ssh_host_* \
 && groupadd --gid 1000 dev \
 && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash dev \
 && mkdir -p /etc/devbox /run/sshd

COPY sshd_config /etc/ssh/devbox_sshd_config
COPY entrypoint.sh /usr/local/bin/devbox-entrypoint
RUN chmod 0644 /etc/ssh/devbox_sshd_config && chmod 0755 /usr/local/bin/devbox-entrypoint

ENV HF_HOME=/home/dev/.cache/huggingface \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    LANG=C.UTF-8

USER 1000:1000
WORKDIR /home/dev
EXPOSE 2222
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/devbox-entrypoint"]
