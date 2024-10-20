#!/usr/bin/env bash

function install_build_deps() {
    echo "Installing build dependencies..."
    sudo apt install -y build-essential cmake ninja-build
}

function install_window_manager() {
    echo "Installing bspwm and sxhkd..."
    sudo apt install -y bspwm
    echo "Installing polybar..."
    sudo apt install -y polybar
    sudo apt install -y rofi # launcher
}

install_build_deps
install_bspwm_sxhkd_and_polybar
