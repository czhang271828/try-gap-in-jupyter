FROM gapsystem/gap-docker
COPY --chown=1000:1000 . $HOME/GAP_Online
USER gap
WORKDIR $HOME/GAP_Online