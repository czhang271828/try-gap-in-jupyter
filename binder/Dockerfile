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

ENV CONDA_DEFAULT_ENV=gap415
ENV PATH=/opt/conda/envs/gap415/bin:$PATH

# 确保 GAP JupyterKernel 1.5.1 安装在该环境（如果你的 spec 已包含，也不会坏）
RUN python -m pip install --no-cache-dir \
    "git+https://github.com/gap-packages/JupyterKernel.git@v1.5.1"

# 写 kernelspec：gap-4
RUN python - <<'PY'
import json, pathlib
prefix = "/opt/conda/envs/gap415"
kdir = pathlib.Path(prefix) / "share/jupyter/kernels/gap-4"
kdir.mkdir(parents=True, exist_ok=True)
kernel = {
  "argv": [f"{prefix}/bin/jupyter-kernel-gap", "{connection_file}"],
  "display_name": "GAP 4 (Binder gap415)",
  "language": "gap",
  "codemirror_mode": "gap",
  "interrupt_mode": "message",
  "env": {"JUPYTER_GAP_EXECUTABLE": f"{prefix}/bin/gap", "PS1": "$"}
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
