#!/bin/bash

# From the creator of Brokefetch (Oliwier)
# I can proudly present cpuinfo!

GREEN="\033[32m"
RED="\033[31m"
BLUE="\033[34m"
CYAN="\033[36m"
WHITE="\033[37m"
YELLOW="\033[33m"
PURPLE="\033[35m"
BOLD="\033[1m"
RESET="\033[0m"
BLACK="\033[30m"
GRAY="\033[90m"

# CONFIG
CONFIG_FILE="$HOME/.config/brokefetch/config"

# If there is no config – create a default one.
if [[ ! -f "$CONFIG_FILE" ]]; then
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo -e "# Available COLOR_NAME options: RED, GREEN, BLUE, CYAN, WHITE, YELLOW, PURPLE, BLACK, GRAY" > "$CONFIG_FILE"
	echo -e "COLOR_NAME=BLUE" >> "$CONFIG_FILE"
fi

# Load values from the config
source "$CONFIG_FILE"

# Value of the color
COLOR=${!COLOR_NAME}

## Info gathering
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME="$NAME"
    OS_VERSION="$VERSION"
else
    OS_NAME="$(uname -s)"
    OS_VERSION="$(uname -r)"
fi

CPU_NAME="$(lscpu | grep 'Model name' | awk -F: '{print $2}' | xargs)"
BRAND="$(lscpu | grep -Eio 'intel|amd|powerpc' | head -1)"

## Dispplayer!

echo -e "${RESET}${BOLD}OS:${RESER} ${COLOR}${OS_NAME} ${OS_VERSION}${RESET}"
echo -e "${RESET}${BOLD}${RESET}"
echo -e "${RESET}${BOLD}Architecture:${RESET} ${COLOR}$(uname -m)${RESET}"
echo -e "${RESET}${BOLD}Brand:${RESET} ${COLOR}${BRAND}${RESET}"
echo -e "${RESET}${BOLD}Model:${RESET} ${COLOR}${CPU_NAME}${RESET}"
echo -e "${RESET}${BOLD}Cores:${RESET} ${COLOR}$(nproc)${RESET}"
