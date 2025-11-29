# Nameing changed from l4t
# https://catalog.ngc.nvidia.com/orgs/nvidia/containers/12.6.11-devel?version=12.6.11-devel-aarch64-ubuntu22.04
FROM nvcr.io/nvidia/12.6.11-devel:12.6.11-devel-aarch64-ubuntu22.04 AS builder

# CTranslate2 build configuration
ARG CTRANSLATE_VERSION=4.6.1
ARG CTRANSLATE_BRANCH=v${CTRANSLATE_VERSION}
ENV CTRANSLATE_SOURCE=/tmp/ctranslate2

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    python3 \
    python3-pip \
    python3-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Download cuDNN local installer
RUN wget -O /tmp/cudnn.deb \
    "https://developer.download.nvidia.com/compute/cudnn/9.1.1/local_installers/cudnn-local-tegra-repo-ubuntu2204-9.1.1_1.0-1_arm64.deb"

# Install cuDNN local repo .deb
RUN apt-get update && \
    apt-get install -y --no-install-recommends /tmp/cudnn.deb && \
    rm -f /tmp/cudnn.deb && \
    rm -rf /var/lib/apt/lists/*

# Copy cuDNN keyring to system keyrings
RUN cp /var/cudnn-local-tegra-repo-ubuntu2204-9.1.1/cudnn-*-keyring.gpg /usr/share/keyrings/

# Install cudnn-cuda-12 from the cuDNN repo
RUN apt-get update && \
    apt-get install -y --no-install-recommends cudnn-cuda-12 && \
    rm -rf /var/lib/apt/lists/*

# Install uv for faster Python package installation
RUN python3 -m pip install --no-cache-dir uv

# Copy the build script
COPY build_ctranslate2 /build_ctranslate2
RUN chmod +x /build_ctranslate2

RUN /build_ctranslate2