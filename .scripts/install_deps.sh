#!/usr/bin/env bash

if [ -e /etc/os-release ]; then
    if [ -n "$$(grep -Ei 'debian|ubuntu' /etc/os-release)" ]; then
        echo "Running on Debian-based system."
        ./.scripts/install_deps-debian.sh
    elif [ -n "$$(grep -Ei 'arch' /etc/os-release)" ]; then
        echo "Running on Arch-based system."
        ./.scripts/install_deps-arch.sh
    else
        echo "Unknown Linux distribution. Cannot install dependencies."
    fi
elif [ "$(uname -s)" == "Darwin" ]; then
    echo "Running on MacOS."
    ./.scripts/install_deps-macos.sh
else
    echo "Unsupported operating system. Cannot install dependencies."
fi
