FROM quay.io/jupyter/minimal-notebook:2025-12-31

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates \
    # 可选但建议：有些 GAP 相关包/ZeroMQInterface 在某些环境需要系统 libzmq
    libzmq3-dev \
 && rm -rf /var/lib/apt/lists/*
USER ${NB_UID}

# 用 explicit spec 创建环境：不求解，避免 Binder OOM
COPY binder/conda-linux-64.txt /tmp/conda-linux-64.txt
RUN mamba create -y -n gap415 --file /tmp/conda-linux-64.txt && \
    mamba clean -afy

# ✅ 关键：把 GAP JupyterKernel 安装到 gap415 环境（不要影响 base server）
RUN /opt/conda/envs/gap415/bin/python -m pip install --no-cache-dir \
    "git+https://github.com/gap-packages/JupyterKernel.git@v1.5.1"

# ✅ 关键：写一个 wrapper，强制带上 gap415 的 PATH 和 JUPYTER_GAP_EXECUTABLE
USER root
RUN cat > /opt/conda/bin/gap415-kernel <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/conda/envs/gap415/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
expo
