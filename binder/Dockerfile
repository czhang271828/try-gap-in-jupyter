FROM quay.io/jupyter/minimal-notebook:2025-12-31

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# 固定版本，避免混装
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

# 安装 GAP JupyterKernel 1.5.1
RUN python -m pip install --no-cache-dir \
    "git+https://github.com/gap-packages/JupyterKernel.git@v1.5.1"

# 写 kernelspec：gap-4（标准 heredoc，不要反斜杠续行）
RUN python - <<'PY'
import json, os, pathlib

prefix = os.environ.get("CONDA_PREFIX", "/opt/conda")
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

# 不自动开浏览器
RUN mkdir -p /home/${NB_USER}/.jupyter && \
    printf "c.ServerApp.open_browser = False\n" > /home/${NB_USER}/.jupyter/jupyter_server_config.py

# Binder 约定：把仓库 COPY 到 $HOME 并 chown
USER root
COPY . ${HOME}
RUN chown -R ${NB_UID}:${NB_GID} ${HOME}
USER ${NB_UID}

WORKDIR ${HOME}
