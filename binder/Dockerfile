# The base image already comes with JupyterLab and a few other goodies
FROM jupyter/scipy-notebook:latest

# We need to run the rest of the build as root
USER root

# Install dependencies needed to build GAP from source
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    autoconf \
    git \
    wget \
    vim \
    m4 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone the git repository and check out the specific version tag
RUN git clone https://github.com/gap-system/gap.git /usr/local/gap && \
    cd /usr/local/gap && \
    git checkout v4.15.1

# Build GAP by compiling the source from the git repository
RUN cd /usr/local/gap && \
    ./autogen.sh && \
    ./configure && \
    make

# CRITICAL STEP: Copy the custom wrapper script into the container's PATH
COPY gap-jupyter /usr/local/bin/
RUN chmod +x /usr/local/bin/gap-jupyter

# Switch back to the notebook user for the final installation
USER ${NB_USER}

# The following command uses the wrapper script to correctly install the kernel.
RUN /usr/local/bin/gap-jupyter install --user
