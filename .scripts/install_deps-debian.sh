#!/bin/bash

function install_nala() {
    echo "Installing Nala..."
    echo "deb http://deb.volian.org/volian/ scar main" | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
    wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg
    sudo apt update
    sudo apt install nala
    if command -v nala &>/dev/null; then
        echo "Nala has been installed!"
        sudo nala fetch
    fi
}

if ! command -v nala &>/dev/null; then
    install_nala
else
    echo "Nala is already installed!"
fi
