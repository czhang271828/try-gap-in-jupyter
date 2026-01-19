# The base image already comes with JupyterLab and a few other goodies
FROM jupyter/scipy-notebook:latest

# We need to run the rest of the build as root
USER root

# Install dependencies needed to build GAP from source
# The 'm4' package is required, as we discovered.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    autoconf \
    git \
    wget \
    vim \
    m4 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# The correct method is to clone the git repository, not download a tarball.
# We then check out the specific version tag that you want.
RUN git clone https://github.com/gap-system/gap.git /usr/local/gap && \
    cd /usr/local/gap && \
    git checkout v4.15.1

# Build GAP by compiling the source from the git repository.
# The './autogen.sh' step is critical and was missing from my previous attempts.
# We do NOT run 'make install'.
RUN cd /usr/local/gap && \
    ./autogen.sh && \
    ./configure && \
    make

# Switch back to the notebook user for the final steps
USER ${NB_USER}

# Install the Jupyter kernel for GAP.
# This command was correct, pointing to the script inside the source tree.
RUN /usr/local/gap/bin/BuildPackages.sh --with-gaproot=/usr/local/gap jupyter

# The following command makes sure that the GAP kernel is available
# in Jupyter for the current user.
# THIS IS THE CRITICAL FIX: The correct script is located in the 'run' directory.
RUN /usr/local/gap/run/gap.sh --jupyter-install-kernel --user
