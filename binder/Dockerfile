FROM quay.io/jupyter/minimal-notebook:2025-12-31

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
        git ca-certificates m4 libzmq3-dev build-essential \
 && rm -rf /var/lib/apt/lists/*
USER ${NB_UID}

# 1) 仅使用 base 环境，避免跨环境 PATH/资源问题
RUN mamba install -y -n base -c conda-forge \
        gap=4.15.1 jupyterlab jupyter_console pyzmq && \
        mamba clean -afy

# 2) 在 base 安装 JupyterKernel (Python 部分)
RUN /opt/conda/bin/python -m pip install --no-cache-dir \
        "git+https://github.com/gap-packages/JupyterKernel.git@master"

# 3) 安装 GAP 的 JupyterKernel 包到 GAP pkg 目录（GAP 侧需要）
USER root
RUN mkdir -p /opt/conda/share/gap/pkg && \
                git clone --depth 1 --branch master https://github.com/gap-packages/JupyterKernel.git \
                        /opt/conda/share/gap/pkg/JupyterKernel && \
                cd /opt/conda/share/gap/pkg/JupyterKernel && \
                (if [ -f configure ]; then ./configure /opt/conda/share/gap && make; fi) && \
                chown -R ${NB_UID}:${NB_GID} /opt/conda/share/gap/pkg/JupyterKernel
USER ${NB_UID}

# 4) 构建时自检：确保 GAP 能加载 JupyterKernel
RUN /opt/conda/bin/gap -q -T <<'GAP'
LoadPackage("JupyterKernel");
QUIT_GAP(0);
GAP

# 5) kernelspec：放到 base 的 share 里，直接调用 jupyter-kernel-gap
RUN /opt/conda/bin/python - <<'PY'
import json, pathlib
kdir = pathlib.Path("/opt/conda/share/jupyter/kernels/gap-4")
kdir.mkdir(parents=True, exist_ok=True)
kernel = {
    "argv": [
        "/opt/conda/bin/jupyter-kernel-gap",
        "{connection_file}"
    ],
    "display_name": "GAP 4 (Binder base)",
    "language": "gap",
    "codemirror_mode": "gap",
    "env": {
        "JUPYTER_GAP_EXECUTABLE": "/opt/conda/bin/gap",
        "PATH": "/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    }
}
(kdir / "kernel.json").write_text(json.dumps(kernel, indent=2))
print("Wrote kernelspec:", kdir / "kernel.json")
PY

# 6) 基本 server 配置：不自动开浏览器 + 开启 DEBUG 日志（用户级 + 系统级）
USER root
ENV JUPYTER_CONFIG_PATH=/etc/jupyter
RUN mkdir -p /home/${NB_USER}/.jupyter /etc/jupyter && \
    printf "c.ServerApp.open_browser = False\n" > /home/${NB_USER}/.jupyter/jupyter_server_config.py && \
    printf "c.ServerApp.log_level = 'DEBUG'\n" >> /home/${NB_USER}/.jupyter/jupyter_server_config.py && \
    printf "c.ServerApp.log_file = '/tmp/jupyter_debug.log'\n" >> /home/${NB_USER}/.jupyter/jupyter_server_config.py && \
    printf "c.ServerApp.open_browser = False\n" > /etc/jupyter/jupyter_server_config.py && \
    printf "c.ServerApp.log_level = 'DEBUG'\n" >> /etc/jupyter/jupyter_server_config.py && \
    printf "c.ServerApp.log_file = '/tmp/jupyter_debug.log'\n" >> /etc/jupyter/jupyter_server_config.py && \
    touch /tmp/jupyter_debug.log && chmod 666 /tmp/jupyter_debug.log && \
    chown -R ${NB_UID}:${NB_GID} /home/${NB_USER}/.jupyter
USER ${NB_UID}

# 7) Binder 约定：复制仓库到 $HOME 并修正权限
USER root
COPY . ${HOME}
RUN chown -R ${NB_UID}:${NB_GID} ${HOME}
USER ${NB_UID}

WORKDIR ${HOME}
