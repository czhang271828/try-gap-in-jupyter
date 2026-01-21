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

# ✅ 关键：把 GAP JupyterKernel 安装到 gap415 环境（不要影响 base server）
RUN /opt/conda/envs/gap415/bin/python -m pip install --no-cache-dir \
    "git+https://github.com/gap-packages/JupyterKernel.git@v1.5.1"

# 写 kernelspec：放到 base 的 share 里，让 base 的 JupyterLab 能看到
RUN /opt/conda/bin/python - <<'PY'
import json, pathlib
base = "/opt/conda"
env  = "/opt/conda/envs/gap415"

kdir = pathlib.Path(base) / "share/jupyter/kernels/gap-4"
kdir.mkdir(parents=True, exist_ok=True)

kernel = {
  "argv": [f"{env}/bin/jupyter-kernel-gap", "{connection_file}"],
  "display_name": "GAP 4 (Binder gap415)",
  "language": "gap",
  "codemirror_mode": "gap",
  "interrupt_mode": "message",
  "env": {
    # 关键：让 kernel 进程的 PATH 能找到 gap
    "PATH": f"{env}/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    # 同时保留显式可执行文件（更稳）
    "JUPYTER_GAP_EXECUTABLE": f"{env}/bin/gap",
    "PS1": "$"
  }
}

(kdir / "kernel.json").write_text(json.dumps(kernel, indent=2))
print("Wrote kernelspec:", kdir / "kernel.json")
PY


# （可选）保留你之前的配置；对 WS 不一定有用，但无害
RUN mkdir -p /home/${NB_USER}/.jupyter && \
    cat > /home/${NB_USER}/.jupyter/jupyter_server_config.py <<'EOF'
c.ServerApp.open_browser = False
EOF

USER root
COPY . ${HOME}
RUN chown -R ${NB_UID}:${NB_GID} ${HOME}
USER ${NB_UID}

WORKDIR ${HOME}
