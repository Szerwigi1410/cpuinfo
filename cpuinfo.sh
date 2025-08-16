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

# Bright colors
BRIGHT_RED="\033[91m"
BRIGHT_GREEN="\033[92m"
BRIGHT_YELLOW="\033[93m"
BRIGHT_BLUE="\033[94m"
BRIGHT_PURPLE="\033[95m"
BRIGHT_CYAN="\033[96m"
BRIGHT_WHITE="\033[97m"

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

# Check if lscpu is installed
if ! command -v lscpu &> /dev/null; then
    echo -e "${RED}Error code 001: lscpu is not installed on your system.${RESET}"
    exit 1
fi

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

CPU_SCL="$(lscpu | grep 'CPU(s) scaling MHz:' | awk -F: '{print $2}' | xargs | sed 's/\.[0]*$//')"
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

# ASCII art override
ASCII_OVERRIDE=""

while getopts ":ha:" option; do
    case $option in
        h) 
            echo "Usage:"
            echo "-a [cpu brand here] to overrite ascii art"
            echo "-h to display this help screen"
            echo -e "The config file is located at ${BOLD}~/.config/cpuinfo/${RESET}"
            exit;;
        a)  
            ASCII_OVERRIDE="$OPTARG"
            ;;
        *)  
            echo -e "${RED}Unknown option:${RESET} -$OPTARG"
            echo "Use '-h' to display the help screen"
            exit;;
    esac
done
shift $((OPTIND-1))

#normalize uppercase and lowercase
if [[ -n "$ASCII_OVERRIDE" ]]; then
    BRAND_TO_DISPLAY=$(echo "$ASCII_OVERRIDE" | tr '[:upper:]' '[:lower:]')
else
    BRAND_TO_DISPLAY=$(echo "$BRAND" | tr '[:upper:]' '[:lower:]')
fi

# Reset ASCII variables before assigning
unset ascii00 ascii01 ascii02 ascii03 ascii04 ascii05 ascii06 ascii07 ascii08 ascii09 ascii10 ascii11 ascii12 ascii13 ascii14 ascii15 ascii16 ascii17 ascii18 ascii19

# Reset info variables before assigning
unset info00 info01 info02 info03 info04 info05 info06 info07 info08 info09 info10 info11 info12 info13

# CPU ascII art
case "$BRAND_TO_DISPLAY" in
    "intel")
        ascii00="${CYAN}88                              88  "
        ascii01="${CYAN}--              ,d              88  "
        ascii02="${CYAN}88              88              88"
        ascii03="${CYAN}88 8b,dPPYba, MM88MMM ,adPPYba, 88  "
        ascii04="${CYAN}88 88P'   \`\"8a  88   a8P_____88 88  "
        ascii05="${CYAN}88 88       88  88   8PP\"\"\"\"\"\"\" 88  "
        ascii06="${CYAN}88 88       88  88,  \"8b,   ,aa 88  "
        ascii07="${CYAN}88 88       88  \"Y888 \`\"Ybbd8\"' 88  "
        ascii08="${CYAN}"
        ;;
    "amd")
        ascii00="${GREEN}   ⠀⠀⠀⠀⠀⠲⣶⣶⢶⡶⣶⢶⡶⣶⢶⠀⠀⠀⠀⠀"
        ascii01="${GREEN}   ⠀⠀⠀⠀⠀⠀⠈⢫⠿⠽⠯⠿⣽⢯⣟⠀⠀⠀⠀⠀"
        ascii02="${GREEN}   ⠀⠀⠀⠀⠀⠀⣠⣿⠀⠀⠀⠀⣟⡿⣽⠀⠀⠀⠀⠀"
        ascii03="${GREEN}   ⠀⠀⠀⠀⠀⣼⣟⡷⠀⠀⠀⠀⣯⢿⡽⠀⠀⠀⠀⠀"
        ascii04="${GREEN}   ⠀⠀⠀⠀⠀⣟⡾⣽⣻⣟⡿⠋⠙⢯⣿⠀⠀⠀⠀⠀"
        ascii05="${GREEN}   ⠀⠀⠀⠀⠀⠛⠙⠓⠛⠊⠀⠀⠀⠀⠙⠀⠀⠀⠀⠀"
        ascii06="${GRAY} ⠀⠀⢸⣿⣿⠀⠀⢸⣿⣦⢠⣾⣿⠀⣿⡿⠿⣿⣦⠀"
        ascii07="${GRAY}  ⢠⣿⣇⣿⣧⠀⢸⣿⢻⡿⢻⣿⠀⣿⡇⠀⢸⣿⡆"
        ascii08="${GRAY} ⢀⣾⡟⠛⠛⢿⣇⢸⣿⠀⠀⢸⣿⠀⣿⣷⣶⠾⠟⠀"
        ;;
    "powerpc")
        ascii00="${BRIGHT_RED}   =%%%%%#=                                .#%%%%%*..+#%%%%#"
        ascii01="${RED}  :#%%*#%%#-+***+:+*=:+++:=*+=+*##*: +*+=+++%%#*%%%+#%%#+++:"
        ascii02="${BRIGHT_RED}  *%%*=#%%#%%#%%%*%%##%%%*%%#%%%#%@*+%%@@%*%%%=+%%**##+.    "
        ascii03="${RED} =%%##@%#*##*-*##*%%%%%%%%%*#%#+%%%+%%%*--#%%*%%%++%%%:     "
        ascii04="${BRIGHT_RED}-%%%==-:.*%%*#%%+*%%%#%%%%=-%%%#**+#%%+  *%%*-=-. =%%%##*.  "
        ascii05="${RED}#%%+     =%%%%#-.#%%==%%%=  =%%%%#*%%#. =%%#:     .*#%%%=   "
        ;;
    "arm")
        ascii00="${BLUE}⠀⠀⠀⣠⣴⣶⣶⣦⣠⣤⣤⣤⡄⠀⠀⣤⣤⣤⣤⣶⣶⣶⡄⢠⣤⣤⣄⣤⣶⣶⣦⣀⢀⣤⣶⣶⣶⣤⠀⠀"
        ascii01="${BLUE}⠀⢰⣿⣿⣿⡿⠿⠿⣿⣿⣿⣿⡇⠀⠀⣿⣿⣿⣿⡿⠿⡿⠁⢸⣿⣿⣿⣿⠿⢿⣿⣿⣿⣿⠿⠿⣿⣿⣿⡄"
        ascii02="${BLUE}⢰⣿⣿⣿⠇⠀⠀⠀⠈⣿⣿⣿⡇⠀⠀⣿⣿⣿⠆⠀⠀⠀⠀⢸⣿⣿⣿⠁⠀⠈⣿⣿⣿⡏⠀⠀⢿⣿⣿⡅"
        ascii03="${BLUE}⢸⣿⣿⣟⠀⠀⠀⠀⠀⢹⣿⣿⡇⠀⠀⣿⣿⣿⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⣿⣿⣿⠃⠀⠀⢸⣿⣿⡇"
        ascii04="${BLUE}⠘⣿⣿⣿⠄⠀⠀⠀⢀⣿⣿⣿⡇⠀⠀⣿⣿⣿⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⠀⢸⣿⣿⡇"
        ascii05="${BLUE}⠀⠉⢿⣿⣷⣧⣶⣶⣿⣿⣿⣿⡇⠀⠀⣿⣿⣿⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⠀⢸⣿⣿⡇"
        ascii06="${BLUE}⠀⠀⠈⠉⠻⠿⠟⠟⠙⠚⠛⠛⠃⠀⠀⠛⠛⠛⠀⠀⠀⠀⠀⠈⠛⠛⠛⠀⠀⠀⠛⠛⠛⠀⠀⠀⠘⠛⠛⠀"
        ascii07=""
        ascii08=""
        ;;
    "snapdragon")
        ascii00="${RED}⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⠠⠀⠀${WHITE}⠤⢀⠀⠀⠀⠀⠀⠀⠀"
        ascii01="${RED}⠀⠀⠀⢀⣤⢆⣴⡿⡟⠁⠀⠀⠀⠀⠀⠀${WHITE}⠑⠠⡀⠀⠀⠀"
        ascii02="${RED}⠀⠀⣴⡿⣷⣽⢯⣿⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀${WHITE}⠈⠢⠀⠀"
        ascii03="${RED}⠀⣼⡿⣽⣻⢾⣟⣷⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WHITE}⠡⠀"
        ascii04="${RED}⠠⣿⣽⣻⣽⢿⣞⡿⣾⢷⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WHITE}⢁"
        ascii05="${RED}⠀⠛⣾⣽⡾⣯⡿⣽⣯⢿⣻⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀${WHITE}⢸"
        ascii06="${RED}⠀⠀⠈⠱⢿⣯⣟⣷⣻⢿⡽⣯⣿⣿⣆⠀⠀⠀⠀⠀⠀${WHITE}⢸"
        ascii07="${RED}⢻⣆⣄⠀⠀⠁⠻⣽⣯⣟⣿⣽⣻⣿⣿⡄⠀⠀⠀⠀⠀${WHITE}⡈"
        ascii08="${RED}⠀⢻⣯⢿⣧⣦⡄⡈⢳⡿⣞⣷⢿⣿⣿⠃⠀⠀⠀⠀${WHITE}⡐⠀"
        ascii09="${RED}⠀⠀⠸⣿⣞⡷⣿⣻⢼⣿⢯⣟⣿⣿⠏⠀⠀⠀${WHITE}⢀⠜⠀⠀"
        ascii10="${RED}⠀⠀⠀⠈⠉⠿⣷⣻⣻⣽⣿⡿⠟⠋${WHITE}⡀⢀⠠⠀⠁⠀⠀"
        ;;    
    *)
        ascii00="${WHITE}${BOLD}Damn bro"
        ascii01="${WHITE}${BOLD}Are you THAT broke to not have a normal CPU?"
        ascii02="${WHITE}${BOLD}You should check out Brokefetch!"
        ascii03="${WHITE}${BOLD}On AUR it's known as brokefetch-git"
        ascii04="${WHITE}"
        ascii05="${WHITE}"
        ascii06="${WHITE}"
        ascii07="${WHITE}"
        ascii08="${WHITE}"
        ;;
esac


#info values

info00="${COLOR1}${BOLD}OS:${RESET} ${COLOR}${OS_NAME} ${OS_VERSION}${RESET}" #                                    "
info01="${COLOR1}${BOLD}${RESET}" #                                                   "
info02="${COLOR1}${BOLD}Architecture:${RESET} ${COLOR}$(uname -m)${RESET}" #                                    "
info03="${COLOR1}${BOLD}Brand:${RESET} ${COLOR}${BRAND}${RESET}" #                                                   "
info04="${COLOR1}${BOLD}Model:${RESET} ${COLOR}${CPU_NAME}${RESET}" #                                                   "
info05="${COLOR1}${BOLD}Cores:${RESET} ${COLOR}${CORE_NUM}${RESET}" #                                           "
info06="${COLOR1}${BOLD}Threads:${RESET} ${COLOR}${THREADS}${RESET}" #                                         "
info07="${COLOR1}${BOLD}Threads per core:${RESET} ${COLOR}${THREAD_PER}${RESET}" #                                "
info08="${COLOR1}${BOLD}Min MHz: ${RESET}${COLOR}${MIN_MHZ} Mhz${RESET}" #                                   "
info09="${COLOR1}${BOLD}Max MHz: ${RESET}${COLOR}${MAX_MHZ} Mhz${RESET}" #                                  "
info10="${COLOR1}${BOLD}CPU(s) scaling MHz: ${RESET}${COLOR}${CPU_SCL}${RESET}" #                           "
info11="${COLOR1}${BOLD}L1:${RESET} ${COLOR}${L1}${RESET}"
info12="${COLOR1}${BOLD}L2:${RESET} ${COLOR}${L2}${RESET}"
info13="${COLOR1}${BOLD}L3:${RESET} ${COLOR}${L3}${RESET}"

# Displayer! (dynamic, padded)
info_vars=( "$info00" "$info01" "$info02" "$info03" "$info04" "$info05" "$info06" "$info07" "$info08" "$info09" "$info10" "$info11" "$info12" "$info13" )
ascii_vars=( "$ascii00" "$ascii01" "$ascii02" "$ascii03" "$ascii04" "$ascii05" "$ascii06" "$ascii07" "$ascii08" "$ascii09" "$ascii10" "$ascii11" "$ascii12" "$ascii13" "$ascii14" "$ascii15" "$ascii16" "$ascii17" "$ascii18" "$ascii19" )

# Find max visible length of info variables (ignoring color codes)
max_len=0
for info in "${info_vars[@]}"; do
    visible_len=$(echo -e "$info" | sed 's/\x1b\[[0-9;]*m//g' | wc -c)
    visible_len=$((visible_len - 1))
    (( visible_len > max_len )) && max_len=$visible_len
done

# Pad info variables
for i in "${!info_vars[@]}"; do
    visible_len=$(echo -e "${info_vars[i]}" | sed 's/\x1b\[[0-9;]*m//g' | wc -c)
    visible_len=$((visible_len - 1))
    pad_len=$((max_len - visible_len))
    info_vars[i]="${info_vars[i]}$(printf '%*s' "$pad_len")"
done

# Print info + ASCII
for i in "${!info_vars[@]}"; do
    echo -e "${info_vars[i]}${ascii_vars[i]}"
done