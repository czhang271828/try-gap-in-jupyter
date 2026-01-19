# The base image already comes with JupyterLab and a few other goodies
FROM jupyter/scipy-notebook:latest

# We need to run the rest of the build as root
USER root

# Install dependencies needed to build GAP from source
# added: bison (provides yacc), flex, automake, libtool, pkg-config
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      autoconf \
      automake \
      libtool \
      pkg-config \
      bison \
      flex \
      git \
      wget \
      vim \
      m4 \
      libzmq3-dev \
      ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the desired GAP version (v4.15.1 in this case)
ARG GAP_VERSION=4.15.1

# Clone the GAP source code from GitHub and checkout the specific version tag
RUN git clone https://github.com/gap-system/gap.git /usr/local/gap && \
    cd /usr/local/gap && \
    git checkout v${GAP_VERSION}

# Manually clone ONLY the JupyterKernel package into the 'pkg' directory.
# This is necessary because it's not a submodule for v4.15.1.
RUN git clone https://github.com/gap-packages/JupyterKernel.git /usr/local/gap/pkg/JupyterKernel

# Build GAP by compiling the source from the git repository
# Use parallel make and keep the build as root
RUN cd /usr/local/gap && \
    ./autogen.sh && \
    ./configure && \
    make -j$(nproc)

# Make sure GAP tree is readable/writable by the notebook user
ARG NB_USER=jovyan
ARG NB_UID=1000
ARG NB_GID=100
RUN chown -R ${NB_UID}:${NB_GID} /usr/local/gap

# Copy the custom 'gap-jupyter' wrapper script (which must be in your repo's root)
# Ensure it ends up executable
COPY gap-jupyter /usr/local/bin/gap-jupyter
RUN chmod +x /usr/local/bin/gap-jupyter

# Switch back to the notebook user for the final installation
USER ${NB_USER}

# Use the wrapper script to correctly build and install the Jupyter kernel
RUN /usr/local/bin/gap-jupyter install --user
