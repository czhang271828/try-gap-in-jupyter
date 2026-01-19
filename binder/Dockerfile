FROM jupyter/scipy-notebook:latest

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      autoconf \
      automake \
      libtool \
      pkg-config \
      bison \
      flex \
      git \
      m4 \
      libzmq3-dev \
      ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ARG GAP_VERSION=4.15.1

# Build GAP
RUN git clone https://github.com/gap-system/gap.git /usr/local/gap && \
    cd /usr/local/gap && \
    git checkout v${GAP_VERSION} && \
    ./autogen.sh && \
    ./configure && \
    make -j$(nproc)

# Install JupyterKernel
RUN git clone https://github.com/gap-packages/JupyterKernel.git \
      /usr/local/gap/pkg/JupyterKernel

# Permissions
ARG NB_UID=1000
ARG NB_GID=100
RUN chown -R ${NB_UID}:${NB_GID} /usr/local/gap

# Wrapper
COPY gap-jupyter /usr/local/bin/gap-jupyter
RUN chmod +x /usr/local/bin/gap-jupyter

USER jovyan

# Install kernel
RUN gap-jupyter install --user
