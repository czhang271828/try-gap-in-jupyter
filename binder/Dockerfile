# The base image already comes with JupyterLab and a few other goodies
FROM jupyter/scipy-notebook:latest

# Set the GAP version to be installed
# This version is a pre-release and must be compiled from source.
ARG GAP_VERSION=4.15.1
ARG GAP_ARCHIVE=gap-${GAP_VERSION}.tar.gz
# The URL for pre-releases is on GitHub
ARG GAP_URL=https://github.com/gap-system/gap/releases/download/v${GAP_VERSION}/${GAP_ARCHIVE}

# We need to run the rest of the build as root
USER root

# Install dependencies needed to build GAP from source
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    wget \
    vim && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and extract the GAP source code from the GitHub release
RUN wget -O /tmp/${GAP_ARCHIVE} ${GAP_URL} && \
    tar -xf /tmp/${GAP_ARCHIVE} -C /usr/local && \
    rm /tmp/${GAP_ARCHIVE}

# Build GAP by compiling the source
# We move it to /usr/local/gap so the path doesn't contain the version number
RUN mv /usr/local/gap-${GAP_VERSION} /usr/local/gap && \
    cd /usr/local/gap && \
    ./configure && \
    make

# Switch back to the notebook user
USER ${NB_USER}

# Install the Jupyter kernel for GAP
RUN /usr/local/gap/bin/BuildPackages.sh /usr/local/gap jupyter

# The following command makes sure that the GAP kernel is available
# in Jupyter for the current user.
RUN /usr/local/gap/bin/gap.sh --jupyter-install-kernel --user
