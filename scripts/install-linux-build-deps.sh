#!/usr/bin/env bash

set -euo pipefail

retry() {
  local attempts="$1"
  local delay_seconds="$2"
  shift 2

  local attempt=1
  while true; do
    local status=0
    if "$@"; then
      return 0
    else
      status="$?"
    fi

    if (( attempt >= attempts )); then
      echo "Command failed after ${attempts} attempts: $*" >&2
      return "$status"
    fi

    echo "Attempt ${attempt}/${attempts} failed (exit ${status}): $*" >&2
    echo "Retrying in ${delay_seconds}s..." >&2
    sleep "${delay_seconds}"
    attempt=$((attempt + 1))
  done
}

apt_update() {
  apt-get clean
  rm -rf /var/lib/apt/lists/*
  DEBIAN_FRONTEND=noninteractive apt-get update \
    -o Acquire::Retries=5 \
    -o Acquire::http::Timeout=30 \
    -o Acquire::https::Timeout=30 \
    -o APT::Update::Error-Mode=any
}

install_core_packages() {
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl \
    git \
    openssh-client \
    cmake \
    build-essential \
    clang \
    libclang-dev \
    pkg-config \
    ca-certificates \
    wget \
    gpg
}

install_lunarg_repo() {
  install -d /etc/apt/trusted.gpg.d
  curl -fsSL https://packages.lunarg.com/lunarg-signing-key-pub.asc \
    | tee /etc/apt/trusted.gpg.d/lunarg.asc >/dev/null
  echo "deb https://packages.lunarg.com/vulkan jammy main" \
    | tee /etc/apt/sources.list.d/lunarg-vulkan-jammy.list >/dev/null
}

install_vulkan_sdk() {
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends vulkan-sdk
}

install_nccl() {
  # Pin NCCL to the version matching the container's CUDA toolkit (12.4).
  # Without pinning, apt pulls the latest NCCL (e.g. 2.30.x for CUDA 13.2)
  # which causes undefined-symbol linker errors (ncclCommInitAll, etc.).
  local nccl_ver="${NCCL_VERSION:-2.21.5-1+cuda12.4}"
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --allow-change-held-packages \
    "libnccl-dev=${nccl_ver}" "libnccl2=${nccl_ver}"
}

retry 5 15 apt_update
retry 5 15 install_core_packages
retry 5 15 install_lunarg_repo
retry 5 15 apt_update
retry 5 15 install_vulkan_sdk
retry 5 15 install_nccl
nvcc --version
