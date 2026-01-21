# Binder 要求 FROM 必须带 tag，且不能用 latest :contentReference[oaicite:3]{index=3}
# Jupyter Docker Stacks 现在主要在 Quay.io 发布（Docker Hub 老镜像不再更新）:contentReference[oaicite:4]{index=4}
FROM quay.io/jupyter/minimal-notebook:2025-12-31

ARG GAP_VERSION=4.15.1
ARG JUPYTERKERNEL_TAG=v1.5.1

USER root

# GAP +（可选）JupyterKernel 依赖：
# JupyterKernel 依赖构建 ZeroMQInterface 等包时需要 libzmq3-dev 和 m4 :contentReference[oaicite:5]{index=5}
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    autoconf automake libtool \
    libgmp-dev libreadline-dev zlib1g-dev \
    libzmq3-dev m4 \
    git wget ca-certificates xz-utils \
 && rm -rf /var/lib/apt/lists/*

# 安装 GAP 到 /opt，并让 NB_USER（uid=1000）可写
ENV GAP_ROOT=/opt/gap-${GAP_VERSION}
RUN mkdir -p /opt && chown -R ${NB_UID}:${NB_GID} /opt

USER ${NB_UID}

# 下载并编译 GAP 4.15.1（发布包在 gap-system/gap releases）:contentReference[oaicite:6]{index=6}
# 注意：如果你发现下载 URL 变了，就去 releases 页面复制资产直链即可。
RUN cd /tmp \
 && wget -q -O gap-${GAP_VERSION}.tar.gz \
      https://github.com/gap-system/gap/releases/download/v${GAP_VERSION}/gap-${GAP_VERSION}.tar.gz \
 && tar -xzf gap-${GAP_VERSION}.tar.gz \
 && mv gap-${GAP_VERSION} ${GAP_ROOT} \
 && cd ${GAP_ROOT} \
 && ./configure --with-gmp=system --with-readline=system \
 && make -j"$(nproc)" \
 && cd pkg && ../bin/BuildPackages.sh \
 && rm -rf /tmp/*

# 安装 JupyterKernel（克隆到 GAP pkg 下，然后 pip install . 注册 kernel）:contentReference[oaicite:7]{index=7}
RUN cd ${GAP_ROOT}/pkg \
 && git clone --depth 1 --branch ${JUPYTERKERNEL_TAG} https://github.com/gap-packages/JupyterKernel.git \
 && cd JupyterKernel \
 && python3 -m pip install --no-cache-dir --user .

# 确保 gap 与 jupyter-kernel-gap 可被找到
ENV PATH="/home/${NB_USER}/.local/bin:${PATH}"
ENV JUPYTER_GAP_EXECUTABLE="${GAP_ROOT}/gap"

# --- 下面对应你贴的 COPY/USER/WORKDIR 思路：把仓库放进 HOME 并切到工作目录 ---
# Binder 要求 repo 内容在 $HOME 且归 NB_USER 所有 :contentReference[oaicite:8]{index=8}
USER root
COPY . ${HOME}/try-gap-in-jupyter
RUN chown -R ${NB_UID}:${NB_GID} ${HOME}/try-gap-in-jupyter
WORKDIR ${HOME}/try-gap-in-jupyter
