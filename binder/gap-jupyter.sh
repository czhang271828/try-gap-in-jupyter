#!/bin/bash
# A wrapper for the GAP Jupyter kernel, see
# https://github.com/gap-system/JupyterKernel

# ensure that this script is run with bash
if [ -z "$BASH_VERSION" ]; then
    exec bash "$0" "$@"
fi

# path to GAP root directory, autodetected
GAP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../gap"
if [ ! -f "$GAP_DIR/sysinfo.gap" ]; then
    GAP_DIR="/usr/local/gap"
fi

# path to the real kernel
KERNEL="$GAP_DIR/pkg/JupyterKernel/bin/jupyter-kernel.py"

# helper function to build a package
build_pkg() {
    "$GAP_DIR/bin/BuildPackages.sh" --with-gaproot="$GAP_DIR" "$1"
}

# ensure that all required packages are build
build_pkg "JupyterKernel"
build_pkg "zeromq"

# now run the kernel
exec "$KERNEL" "$@"
