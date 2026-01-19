# The base image already comes with JupyterLab and a few other goodies
FROM jupyter/scipy-notebook:latest

# Set the GAP version to be installed from the .sh installer
# This points to the latest recommended version from https://www.gap-system.org/install/linux/
ARG GAP_VERSION=4.15.1
ARG GAP_INSTALLER=gap-${GAP_VERSION}.sh
ARG GAP_URL=https://www.gap-system.org/pub/gap/gap-4.15/${GAP_INSTALLER}

# We need to run the rest of the build as root
USER root

# Install dependencies. The installer script is mostly self-contained,
# but we still need wget to download it.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Download the installer, make it executable, and run it.
# The `yes |` command automatically answers 'yes' to the license prompt,
# allowing the script to run non-interactively.
# The script will create a directory named `gap-4.15.1` in the root ('/') directory.
RUN wget -O /tmp/${GAP_INSTALLER} ${GAP_URL} && \
    chmod +x /tmp/${GAP_INSTALLER} && \
    yes | /tmp/${GAP_INSTALLER}

# Move the installed directory to a clean, version-independent path and remove the installer script
RUN mv /gap-${GAP_VERSION} /usr/local/gap && \
    rm /tmp/${GAP_INSTALLER}

# Switch back to the notebook user for the final steps
USER ${NB_USER}

# The Jupyter package is not built by default with the installer, so we need to build it.
# This command tells GAP to find and build the 'jupyter' package.
RUN /usr/local/gap/bin/BuildPackages.sh /usr/local/gap jupyter

# This final command makes the GAP kernel available in Jupyter for the current user.
RUN /usr/local/gap/bin/gap.sh --jupyter-install-kernel --user
