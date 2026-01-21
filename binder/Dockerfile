FROM quay.io/jupyter/minimal-notebook:2025-12-31

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates \
 && rm -rf /var/lib/apt/lists/*
USER ${NB_UID}

# 用 explicit spec 创建环境：不求解，避免 Binder OOM
COPY binder/conda-linux-64.txt /tmp/conda-linux-64.txt
RUN mamba create -y -n gap415 --file /tmp/conda-linux-64.txt && \
    mamba clean -afy

# 把 GAP JupyterKernel 安装到 gap415 环境（不要影响 base server）
RUN /opt/conda/envs/gap415/bin/python -m pip install --no-cache-dir \
    "git+https://github.com/gap-packages/JupyterKernel.git@v1.5.1"

# 创建 wrapper：强制 PATH + JUPYTER_GAP_EXECUTABLE，再启动 jupyter-kernel-gap
USER root
RUN printf '%s\n' \
'#!/usr/bin/env bash' \
'set -euo pipefail' \
'' \
'export PATH="/opt/conda/envs/gap415/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"' \
'export JUPYTER_GAP_EXECUTABLE="/opt/conda/envs/gap415/bin/gap"' \
'' \
'exec /opt/conda/envs/gap415/bin/jupyter-kernel-gap "$@"' \
> /opt/conda/bin/gap415-kernel && chmod +x /opt/conda/bin/gap415-kernel
USER ${NB_UID}

# 写 kernelspec：放到 base 的 share 里，让 base 的 JupyterLab 能看到
RUN /opt/conda/bin/python - <<'PY'
import json, pathlib
kdir = pathlib.Path("/opt/conda/share/jupyter/kernels/gap-4")
kdir.mkdir(parents=True, exist_ok=True)
kernel = {
  "argv": ["/opt/conda/bin/gap415-kernel", "{connection_file}"],
  "display_name": "GAP 4 (Binder gap415)",
  "language": "gap",
  "codemirror_mode": "gap",
  "interrupt_mode": "message"
}
(kdir / "kernel.json").write_text(json.dumps(kernel, indent=2))
print("Wrote kernelspec:", kdir / "kernel.json")
PY

# 不自动开浏览器
RUN mkdir -p /home/${NB_USER}/.jupyter && \
    printf "c.ServerApp.open_browser = False\n" > /home/${NB_USER}/.jupyter/jupyter_server_config.py

USER root
COPY . ${HOME}
RUN chown -R ${NB_UID}:${NB_GID} ${HOME}
USER ${NB_UID}

WORKDIR ${HOME}
