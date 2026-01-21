FROM quay.io/jupyter/minimal-notebook:2025-12-31

ARG GAP_VERSION=4.15.1
ARG JUPYTERKERNEL_TAG=v1.5.1

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgmp-dev libreadline-dev zlib1g-dev \
    libzmq3-dev m4 \
    git wget ca-certificates xz-utils \
 && rm -rf /var/lib/apt/lists/*

ENV GAP_ROOT=/opt/gap-${GAP_VERSION}
RUN mkdir -p /opt && chown -R ${NB_UID}:${NB_GID} /opt

USER ${NB_UID}

# 用 core 包（小很多，构建更稳）:contentReference[oaicite:5]{index=5}
RUN cd /tmp \
 && wget -q -O gap-${GAP_VERSION}-core.tar.gz \
      https://github.com/gap-system/gap/releases/download/v${GAP_VERSION}/gap-${GAP_VERSION}-core.tar.gz \
 && tar -xzf gap-${GAP_VERSION}-core.tar.gz \
 && mv gap-${GAP_VERSION} ${GAP_ROOT} \
 && cd ${GAP_ROOT} \
 && ./configure --with-gmp=system --with-readline=system \
 && make -j"$(nproc)" \
 && rm -rf /tmp/*

# 装 JupyterKernel（GAP 的 Jupyter kernel 包）
RUN cd ${GAP_ROOT}/pkg \
 && git clone --depth 1 --branch ${JUPYTERKERNEL_TAG} https://github.com/gap-packages/JupyterKernel.git \
 && cd JupyterKernel \
 && python3 -m pip install --no-cache-dir --user .

ENV PATH="/home/${NB_USER}/.local/bin:${PATH}"
ENV JUPYTER_GAP_EXECUTABLE="${GAP_ROOT}/gap"

# 把仓库复制到 $HOME（Binder 约定）
USER root
COPY . ${HOME}
RUN chown -R ${NB_UID}:${NB_GID} ${HOME}
USER ${NB_UID}

WORKDIR ${HOME}
