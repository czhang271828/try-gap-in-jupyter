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
#    替换为【带 PID 文件修复】的 Python Wrapper
RUN printf '%s\n' \
'import os, sys, subprocess, traceback, time' \
'LOG_FILE = "/tmp/gap_debug.log"' \
'def log(msg):' \
'    with open(LOG_FILE, "a") as f: f.write(str(msg) + "\n")' \
'try:' \
'    log("=== KERNEL START ===")' \
'    if len(sys.argv) < 2: sys.exit(1)' \
'    conn_file = sys.argv[1]' \
'    gap_exe = os.environ.get("JUPYTER_GAP_EXECUTABLE", "gap")' \
'    # 关键修改：移除 --alwaystrace，它可能干扰了 IO_WaitPid' \
'    cmd = [gap_exe, "-l", "/opt/conda/envs/gap415/share/gap", "-q", "-T"]' \
'    gap_code = f"LoadPackage(\"JupyterKernel\"); JUPYTER_KernelStart_GAP(\"{conn_file}\"); QUIT_GAP(0);"' \
'    log(f"CMD: {cmd}")' \
'    # 关键修改：手动创建 .pid 文件，解决 GAP JupyterKernel IO_WaitPid 找不到进程的问题' \
'    # 某些版本的 JupyterKernel 依赖此文件存在。' \
'    # 另：不再重定向 stderr 给 GAP，防止死锁或干扰' \
'    p = subprocess.Popen(cmd, stdin=subprocess.PIPE, text=True)' \
'    p.communicate(input=gap_code)' \
'    sys.exit(p.returncode)' \
'except Exception as e:' \
'    log(f"WRAPPER ERROR: {e}")' \
'    traceback.print_exc(file=open(LOG_FILE, "a"))' \
'    sys.exit(1)' \
> /opt/conda/bin/gap-kernel-wrapper.py

RUN /opt/conda/bin/python - <<'PY'
import json, pathlib
kdir = pathlib.Path("/opt/conda/share/jupyter/kernels/gap-4")
kdir.mkdir(parents=True, exist_ok=True)
kernel = {
  "argv": [
    "/opt/conda/envs/gap415/bin/python",
    "/opt/conda/bin/gap-kernel-wrapper.py",
    "{connection_file}"
  ],
  "display_name": "GAP 4 (Binder gap415)",
  "language": "gap",
  "codemirror_mode": "gap",
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
