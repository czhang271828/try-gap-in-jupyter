FROM gapsystem/gap-docker

# 安装 pyvis 库
RUN pip install pyvis

COPY --chown=1000:1000 . $HOME/GAP_Online

USER gap

WORKDIR $HOME/GAP_Online
