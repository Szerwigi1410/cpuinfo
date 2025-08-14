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
CONFIG_FILE="$HOME/.config/cpuinfo/config"

# If there is no config – create a default one.
if [[ ! -f "$CONFIG_FILE" ]]; then
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo -e "# Available COLOR_NAME options: RED, GREEN, BLUE, CYAN, WHITE, YELLOW, PURPLE, BLACK, GRAY" > "$CONFIG_FILE"
	echo -e "COLOR_NAME=WHITE" >> "$CONFIG_FILE"
    echo -e "SECOND_COLOR_NAME=BLUE" >> "$CONFIG_FILE"
fi

# Load values from the config
source "$CONFIG_FILE"

# Value of the color
COLOR=${!COLOR_NAME}
COLOR1=${!SECOND_COLOR_NAME}

## Info gathering
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME="$NAME"
    OS_VERSION="$VERSION"
else
    OS_NAME="$(uname -s)"
    OS_VERSION="$(uname -r)"
fi

# CPU information
CPU_NAME="$(lscpu | grep 'Model name' | awk -F: '{print $2}' | xargs)"

BRAND="$(lscpu | grep -Eio 'intel|amd|powerpc' | head -1)"
if [ -z "$BRAND" ]; then
    BRAND="Unknown"
fi

# Number of cores
CORE_NUM="$(lscpu | grep 'Core(s) per socket' | awk -F: '{print $2}' | xargs)"

# Threads

THREADS="$(nproc)"

THREAD_PER="$(lscpu | grep 'Thread(s) per core' | awk -F: '{print $2}' | xargs)"

# MHz
MIN_MHZ="$(lscpu | grep 'CPU min MHz' | awk -F: '{print $2}' | xargs | sed 's/\.[0]*$//')"
MAX_MHZ="$(lscpu | grep 'CPU max MHz' | awk -F: '{print $2}' | xargs | sed 's/\.[0]*$//')"
CUR_MHZ="$(lscpu | grep 'CPU MHz' | awk -F: '{print $2}' | xargs | sed 's/\.[0]*$//')"

# Fallback if min/max are empty
if [[ -z "$MIN_MHZ" ]]; then
    MIN_MHZ="$CUR_MHZ"
fi
if [[ -z "$MAX_MHZ" ]]; then
    MAX_MHZ="$CUR_MHZ"
fi

#cache
L1="$(lscpu | grep 'L1' |awk -F: '{print $2}'| xargs |head -1)"
L2="$(lscpu | grep 'L2' |awk -F: '{print $2}'| xargs)"
L3="$(lscpu | grep 'L3' |awk -F: '{print $2}'| xargs)"


ASCII_OVERRIDE=""

while getopts ":a:" option; do
    case $option in
        a)
            ASCII_OVERRIDE="$OPTARG"
            ;;
        *)
            ;;
    esac
done
shift $((OPTIND-1))

if [[ -n "$ASCII_OVERRIDE" ]]; then
    BRAND_TO_DISPLAY=$(echo "$ASCII_OVERRIDE" | tr '[:upper:]' '[:lower:]')
else
    BRAND_TO_DISPLAY=$(echo "$BRAND" | tr '[:upper:]' '[:lower:]')
fi


# CPU ascII art
case "$BRAND_TO_DISPLAY" in
    "intel")
        ascii00="                                    88                              88  "
        ascii01="                                                   --              ,d              88  "
        ascii02="                               88              88  "
        ascii03="                                       88 8b,dPPYba, MM88MMM ,adPPYba, 88  "
        ascii04="    88 88P'   \`\"8a  88   a8P_____88 88  "
        ascii05="                                           88 88       88  88   8PP\"\"\"\"\"\"\" 88  "
        ascii06="                                         88 88       88  88,  \"8b,   ,aa 88  "
        ascii07="                                88 88       88  \"Y888 \`\"Ybbd8\"' 88  "
        ascii08=""
        ;;
    "amd")
        ascii00="${GREEN}                                   ⠀⠀⠀⠀⠀⠲⣶⣶⢶⡶⣶⢶⡶⣶⢶⠀⠀⠀⠀⠀"
        ascii01="${GREEN}                                                  ⠀⠀⠀⠀⠀⠀⠈⢫⠿⠽⠯⠿⣽⢯⣟⠀⠀⠀⠀⠀"
        ascii02="${GREEN}                              ⠀⠀⠀⠀⠀⠀⣠⣿⠀⠀⠀⠀⣟⡿⣽⠀⠀⠀⠀⠀"
        ascii03="${GREEN}                                      ⠀⠀⠀⠀⠀⣼⣟⡷⠀⠀⠀⠀⣯⢿⡽⠀⠀⠀⠀⠀"
        ascii04="${GREEN}   ⠀⠀⠀⠀⠀⣟⡾⣽⣻⣟⡿⠋⠙⢯⣿⠀⠀⠀⠀⠀"
        ascii05="${GREEN}                                          ⠀⠀⠀⠀⠀⠛⠙⠓⠛⠊⠀⠀⠀⠀⠙⠀⠀⠀⠀⠀"
        ascii06="${GRAY}                                        ⠀⠀⢸⣿⣿⠀⠀⢸⣿⣦⢠⣾⣿⠀⣿⡿⠿⣿⣦⠀"
        ascii07="${GRAY}                                ⢠⣿⣇⣿⣧⠀⢸⣿⢻⡿⢻⣿⠀⣿⡇⠀⢸⣿⡆"
        ascii08="${GRAY}                                  ⢀⣾⡟⠛⠛⢿⣇⢸⣿⠀⠀⢸⣿⠀⣿⣷⣶⠾⠟⠀"
        ;;
    "powerpc")
        
        ;;
    *)
        
        ;;
esac


## Displayer!

echo -e "${COLOR1}${BOLD}OS:${RESET} ${COLOR}${OS_NAME} ${OS_VERSION}${RESET}${ascii00}"
echo -e "${COLOR1}${BOLD}${RESET}${ascii01}"
echo -e "${COLOR1}${BOLD}Architecture:${RESET} ${COLOR}$(uname -m)${RESET}${ascii02}"
echo -e "${COLOR1}${BOLD}Brand:${RESET} ${COLOR}${BRAND}${RESET}${ascii03}"
echo -e "${COLOR1}${BOLD}Model:${RESET} ${COLOR}${CPU_NAME}${RESET}${ascii04}"
echo -e "${COLOR1}${BOLD}Cores:${RESET} ${COLOR}${CORE_NUM}${RESET}${ascii05}"
echo -e "${COLOR1}${BOLD}Threads:${RESET} ${COLOR}${THREADS}${RESET}${ascii06}"
echo -e "${COLOR1}${BOLD}Threads per core:${RESET} ${COLOR}${THREAD_PER}${RESET}${ascii07}"
echo -e "${COLOR1}${BOLD}Min MHz: ${RESET}${COLOR}${MIN_MHZ} Mhz${RESET}${ascii08}"
echo -e "${COLOR1}${BOLD}Max MHz: ${RESET}${COLOR}${MAX_MHZ} Mhz${RESET}"
echo -e "${COLOR1}${BOLD}L1:${RESET} ${COLOR}${L1}${RESET}"
echo -e "${COLOR1}${BOLD}L2:${RESET} ${COLOR}${L2}${RESET}"
echo -e "${COLOR1}${BOLD}L3:${RESET} ${COLOR}${L3}${RESET}"
