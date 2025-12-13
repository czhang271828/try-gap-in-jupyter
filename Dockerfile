FROM gapsystem/gap-docker
COPY --chown=1000:1000 . $HOME/try-gap-in-jupyter
USER gap
WORKDIR $HOME/try-gap-in-jupyter