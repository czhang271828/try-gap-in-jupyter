FROM quay.io/jupyter/minimal-notebook:2025-12-31

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates m4 libzmq3-dev build-essential \
 && rm -rf /var/lib/apt/lists/*
USER ${NB_UID}

# 1) 用 explicit spec 创建环境：不求解，避免 Binder OOM
COPY binder/conda-linux-64.txt /tmp/conda-linux-64.txt
RUN mamba create -y -n gap415 --file /tmp/conda-linux-64.txt && \
    mamba clean -afy

# 2) 给 base 装 jupyter-console（方便在 Binder 终端验证 gap kernel）
RUN mamba install -y -n base -c conda-forge jupyter_console && \
    mamba clean -afy



# 3) 把 GAP JupyterKernel 安装到 gap415 环境（不影响 base 的 Jupyter Server）
#    从 main branch 安装，因为它包含了对新版 tornado/asyncio 的修复
RUN /opt/conda/envs/gap415/bin/python -m pip install --no-cache-dir \
    "git+https://github.com/gap-packages/JupyterKernel.git@master" && \
    mamba clean -afy

# 3.0) 让 base 的 Jupyter Server 能看到 gap 的前端资源/配置
USER root
ENV JUPYTER_PATH=/opt/conda/share/jupyter:/opt/conda/envs/gap415/share/jupyter
ENV JUPYTER_CONFIG_PATH=/opt/conda/etc/jupyter:/opt/conda/envs/gap415/etc/jupyter
RUN mkdir -p /opt/conda/share/jupyter/nbextensions \
        /opt/conda/etc/jupyter/nbconfig/notebook.d && \
        if [ -d /opt/conda/envs/gap415/share/jupyter/nbextensions/gap-mode ]; then \
            ln -s /opt/conda/envs/gap415/share/jupyter/nbextensions/gap-mode \
                /opt/conda/share/jupyter/nbextensions/gap-mode; \
        fi && \
        if [ -f /opt/conda/envs/gap415/etc/jupyter/nbconfig/notebook.d/gap-mode.json ]; then \
            cp /opt/conda/envs/gap415/etc/jupyter/nbconfig/notebook.d/gap-mode.json \
                /opt/conda/etc/jupyter/nbconfig/notebook.d/; \
        fi
USER ${NB_UID}

# 3.1) 安装 GAP 的 JupyterKernel 包到 GAP pkg 目录（GAP 侧需要）
#      尝试编译 C 部分（如果存在 configure），这是 local 正常但 binder 失败的常见原因
USER root
RUN mkdir -p /opt/conda/envs/gap415/share/gap/pkg && \
        git clone --depth 1 --branch master https://github.com/gap-packages/JupyterKernel.git \
            /opt/conda/envs/gap415/share/gap/pkg/JupyterKernel && \
        cd /opt/conda/envs/gap415/share/gap/pkg/JupyterKernel && \
        (if [ -f configure ]; then ./configure /opt/conda/envs/gap415/share/gap && make; fi) && \
        chown -R ${NB_UID}:${NB_GID} /opt/conda/envs/gap415/share/gap/pkg/JupyterKernel
USER ${NB_UID}

# 3.2) 构建时自检：确保 GAP 能加载 JupyterKernel
RUN /opt/conda/envs/gap415/bin/gap -q -T <<'GAP'
LoadPackage("JupyterKernel");
QUIT_GAP(0);
GAP

# 4) (Removed wrapper) - directly use kernel.json env for cleaner execution

# 5) kernelspec：放到 base 的 share 里，让 base 的 JupyterLab 能看到
#    直接调用 python 执行 jupyter-kernel-gap 脚本
#    注意：setup.py 安装的是 bin/jupyter-kernel-gap 脚本，并非可直接 -m 调用的模块
RUN /opt/conda/bin/python - <<'PY'
import json, pathlib
kdir = pathlib.Path("/opt/conda/share/jupyter/kernels/gap-4")
kdir.mkdir(parents=True, exist_ok=True)
kernel = {
  "argv": [
    "/opt/conda/envs/gap415/bin/python",
    "/opt/conda/envs/gap415/bin/jupyter-kernel-gap",
    "{connection_file}"
  ],
  "display_name": "GAP 4 (Binder gap415)",
  "language": "gap",
  "codemirror_mode": "gap",
  "interrupt_mode": "message",
  "env": {
    "JUPYTER_GAP_EXECUTABLE": "/opt/conda/envs/gap415/bin/gap",
    "PATH": "/opt/conda/envs/gap415/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  }
}
(kdir / "kernel.json").write_text(json.dumps(kernel, indent=2))
print("Wrote kernelspec:", kdir / "kernel.json")
PY

# 6) 基本 server 配置：不自动开浏览器
RUN mkdir -p /home/${NB_USER}/.jupyter && \
    printf "c.ServerApp.open_browser = False\n" > /home/${NB_USER}/.jupyter/jupyter_server_config.py

# 7) Binder 约定：复制仓库到 $HOME 并修正权限
USER root
COPY . ${HOME}
RUN chown -R ${NB_UID}:${NB_GID} ${HOME}
USER ${NB_UID}

WORKDIR ${HOME}
