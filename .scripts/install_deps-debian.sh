#!/bin/bash

function install_nala() {
    if ! command -v nala &>/dev/null; then
        echo "Installing Nala..."
        echo "deb http://deb.volian.org/volian/ scar main" | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
        wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg
        sudo apt update
        sudo apt install nala
        if command -v nala &>/dev/null; then
            echo "Nala has been installed!"
            sudo nala fetch
        fi
    else
        echo "Nala is already installed!"
    fi
}

function install_build_deps() {
    echo "Installing build dependencies..."
    sudo nala install -y build-essential cmake ninja-build
}

function install_bspwm_sxhkd_and_polybar() {
    echo "Installing bspwm and sxhkd..."
    sudo nala install -y bspwm
    echo "Installing polybar..."
    sudo nala install -y polybar
}

install_nala
install_build_deps
install_bspwm_sxhkd_and_polybar
