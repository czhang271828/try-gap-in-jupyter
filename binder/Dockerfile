# 必须用固定 tag（不要 latest）
FROM quay.io/jupyter/minimal-notebook:2025-12-31

# Jupyter stacks 默认用户是 jovyan (uid=1000)，符合 Binder 要求
USER root

# 安装一些基础工具（git 用于 pip 从 GitHub 安装 JupyterKernel）
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# 1) 用 mamba/conda 在 base 环境里固定版本安装（避免混装）
#    minimal-notebook 自带 conda/mamba（通常有 mamba；没有的话用 conda 也能跑）
RUN mamba install -y -c conda-forge \
    python=3.11 \
    gap=4.15.1 \
    jupyter_server=2.14.2 \
    jupyterlab=4.3.8 \
    notebook=7.3.3 \
    jupyter_client=8.6.3 \
    jupyter_console \
    pyzmq \
 && mamba clean -afy

# 2) 安装 GAP JupyterKernel 1.5.1
RUN python -m pip install --no-cache-dir \
    "git+https://github.com/gap-packages/JupyterKernel.git@v1.5.1"

# 3) 写入 kernelspec：gap-4
#    - argv 指向本环境的 jupyter-kernel-gap
#    - env 指定 JUPYTER_GAP_EXECUTABLE 为 conda 的 gap
RUN python - <<'PY' \
import json, os, pathlib \
prefix = os.environ.get("CONDA_PREFIX", "/opt/conda") \
kdir = pathlib.Path(prefix) / "share/jupyter/kernels/gap-4" \
kdir.mkdir(parents=True, exist_ok=True) \
kernel = { \
  "argv": [f"{prefix}/bin/jupyter-kernel-gap", "{connection_file}"], \
  "display_name": "GAP 4 (Binder gap415)", \
  "language": "gap", \
  "codemirror_mode": "gap", \
  "interrupt_mode": "message", \
  "env": { \
    "JUPYTER_GAP_EXECUTABLE": f"{prefix}/bin/gap", \
    "PS1": "$" \
  } \
} \
(kdir / "kernel.json").write_text(json.dumps(kernel, indent=2)) \
print("Wrote kernelspec:", kdir / "kernel.json") \
PY

# 4) 避免容器里尝试自动打开浏览器（也避免 Wayland 噪音）
RUN mkdir -p /home/${NB_USER}/.jupyter && \
    printf "c.ServerApp.open_browser = False\n" > /home/${NB_USER}/.jupyter/jupyter_server_config.py

# 5) 复制仓库到 $HOME 并确保权限正确（Binder 要求）
USER root
COPY . ${HOME}
RUN chown -R ${NB_UID}:${NB_GID} ${HOME}
USER ${NB_UID}

WORKDIR ${HOME}
