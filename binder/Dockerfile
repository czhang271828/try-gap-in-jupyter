FROM quay.io/jupyter/minimal-notebook:2025-12-31

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates \
 && rm -rf /var/lib/apt/lists/*
USER ${NB_UID}

# 1) 不改 base：新建独立环境 gap415（更稳）
# 2) 固定你验证过可用的版本
# 3) 强制用 repodata.json，避免 current_repodata.json 不包含旧版本导致找不到
RUN mamba create -y -n gap415 -c conda-forge \
    python=3.11 \
    gap=4.15.1 \
    jupyter_server=2.14.2 \
    jupyterlab=4.3.8 \
    notebook=7.3.3 \
    jupyter_client=8.6.3 \
    jupyter_console \
    pyzmq \
    --repodata-fn repodata.json \
 && mamba clean -afy

# 让容器默认使用 gap415 环境里的 python/jupyter
ENV CONDA_DEFAULT_ENV=gap415
ENV PATH=/opt/conda/envs/gap415/bin:$PATH

# 安装 GAP JupyterKernel 1.5.1 到 gap415 环境
RUN python -m pip install --no-cache-dir \
    "git+https://github.com/gap-packages/JupyterKernel.git@v1.5.1"

# 写 kernelspec：gap-4（指向 gap415 环境）
RUN python - <<'PY'
import json, pathlib, os
prefix = "/opt/conda/envs/gap415"
kdir = pathlib.Path(prefix) / "share/jupyter/kernels/gap-4"
kdir.mkdir(parents=True, exist_ok=True)
kernel = {
  "argv": [f"{prefix}/bin/jupyter-kernel-gap", "{connection_file}"],
  "display_name": "GAP 4 (Binder gap415)",
  "language": "gap",
  "codemirror_mode": "gap",
  "interrupt_mode": "message",
  "env": {
    "JUPYTER_GAP_EXECUTABLE": f"{prefix}/bin/gap",
    "PS1": "$"
  }
}
(kdir / "kernel.json").write_text(json.dumps(kernel, indent=2))
print("Wrote kernelspec:", kdir / "kernel.json")
PY

# 避免容器里尝试自动打开浏览器（也减少 Wayland 噪音）
RUN mkdir -p /home/${NB_USER}/.jupyter && \
    printf "c.ServerApp.open_browser = False\n" > /home/${NB_USER}/.jupyter/jupyter_server_config.py

# Binder 约定：复制仓库到 $HOME 并修正权限
USER root
COPY . ${HOME}
RUN chown -R ${NB_UID}:${NB_GID} ${HOME}
USER ${NB_UID}

WORKDIR ${HOME}
