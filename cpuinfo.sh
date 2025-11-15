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

# Value of the colors
COLOR=${!COLOR_NAME}
COLOR1=${!SECOND_COLOR_NAME}

# Detect OS
OS_TYPE="$(uname -s)"

# Check if lscpu is installed (Linux only)
if ! command -v lscpu &> /dev/null; then
    LSCPU_HERE=false
    if [[ "$OS_TYPE" == "Linux" ]]; then
        echo -e "${RED}Error code 001: lscpu is not installed on your system.${RESET}"
    fi
else
    LSCPU_HERE=true
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

# CPU information - OS specific
if [[ "$OS_TYPE" == "Darwin" ]]; then
    # macOS
    CPU_NAME="$(sysctl -n machdep.cpu.brand_string 2>/dev/null)"
    
    # Detect CPU brand
    BRAND="$(sysctl -n machdep.cpu.vendor 2>/dev/null)"
    if [ -z "$BRAND" ]; then
        # Check for Apple Silicon
        if echo "$CPU_NAME" | grep -qi "apple"; then
            BRAND="ARM"
        elif echo "$CPU_NAME" | grep -qi "intel"; then
            BRAND="Intel"
        elif echo "$CPU_NAME" | grep -qi "amd"; then
            BRAND="AMD"
        else
            BRAND="idk lol"
        fi
    else
        # Normalize vendor name
        if echo "$BRAND" | grep -qi "intel"; then
            BRAND="Intel"
        elif echo "$BRAND" | grep -qi "amd"; then
            BRAND="AMD"
        elif echo "$BRAND" | grep -qi "apple"; then
            BRAND="ARM"
        fi
    fi
    
    CORE_NUM="$(sysctl -n hw.physicalcpu 2>/dev/null)"
    THREADS="$(sysctl -n hw.logicalcpu 2>/dev/null)"
    if [[ -n "$CORE_NUM" && -n "$THREADS" && "$CORE_NUM" -gt 0 ]]; then
        THREAD_PER="$((THREADS / CORE_NUM))"
    else
        THREAD_PER="Unknown"
    fi
    
    # macOS frequencies (in Hz, convert to MHz)
    CUR_MHZ="$(sysctl -n hw.cpufrequency 2>/dev/null | awk '{if($1>0) print int($1/1000000)}')"
    MIN_MHZ="$(sysctl -n hw.cpufrequency_min 2>/dev/null | awk '{if($1>0) print int($1/1000000)}')"
    MAX_MHZ="$(sysctl -n hw.cpufrequency_max 2>/dev/null | awk '{if($1>0) print int($1/1000000)}')"
    
    # Check if this is Apple Silicon
    IS_APPLE_SILICON=false
    if echo "$CPU_NAME" | grep -qiE "Apple M[0-9]|Apple M[0-9] Pro|Apple M[0-9] Max|Apple M[0-9] Ultra"; then
        IS_APPLE_SILICON=true
    fi
    
    # Fallback for Apple Silicon and other Macs where hw.cpufrequency* is not available
    if [[ -z "$CUR_MHZ" || "$CUR_MHZ" == "0" ]]; then
        if $IS_APPLE_SILICON; then
            # Apple Silicon - try to parse from system_profiler or use known values
            CHIP_INFO="$(system_profiler SPHardwareDataType 2>/dev/null | grep "Chip:" | awk -F: '{print $2}' | xargs)"
            if echo "$CHIP_INFO" | grep -qi "M1"; then
                MIN_MHZ="600"      # Efficiency cores min
                MAX_MHZ="3200"     # Performance cores max
                CUR_MHZ="Variable"
            elif echo "$CHIP_INFO" | grep -qi "M2"; then
                MIN_MHZ="600"
                MAX_MHZ="3500"
                CUR_MHZ="Variable"
            elif echo "$CHIP_INFO" | grep -qi "M3"; then
                MIN_MHZ="600"
                MAX_MHZ="4000"
                CUR_MHZ="Variable"
            else
                MIN_MHZ="Dynamic"
                MAX_MHZ="Dynamic"
                CUR_MHZ="Variable"
            fi
        else
            # Intel Mac - try alternative methods
            CUR_MHZ="$(sysctl -n hw.tbfrequency 2>/dev/null | awk '{if($1>0) print int($1/1000000)}')"
            if [[ -z "$CUR_MHZ" ]]; then
                CUR_MHZ="Unknown"
            fi
            MIN_MHZ="${MIN_MHZ:-Unknown}"
            MAX_MHZ="${MAX_MHZ:-$CUR_MHZ}"
        fi
    fi
    
    CPU_SCL=""
    
    # Cache info for macOS
    L1d="$(sysctl -n hw.l1dcachesize 2>/dev/null | awk '{printf "%.0f KiB", $1/1024}')"
    L1i="$(sysctl -n hw.l1icachesize 2>/dev/null | awk '{printf "%.0f KiB", $1/1024}')"
    L2="$(sysctl -n hw.l2cachesize 2>/dev/null | awk '{printf "%.0f KiB", $1/1024}')"
    L3="$(sysctl -n hw.l3cachesize 2>/dev/null | awk '{printf "%.0f KiB", $1/1024}')"
    
    # Clean up "0 KiB" entries
    [[ "$L1d" == "0 KiB" ]] && L1d=""
    [[ "$L1i" == "0 KiB" ]] && L1i=""
    [[ "$L2" == "0 KiB" ]] && L2=""
    [[ "$L3" == "0 KiB" ]] && L3=""
    
else
    # Linux
    CPU_NAME="$(grep -m 1 'model name' /proc/cpuinfo | awk -F: '{print $2}' | xargs)"
    
    BRAND="$(lscpu | grep -Eio 'intel|amd|powerpc' | head -1)"
    if [ -z "$BRAND" ]; then
        BRAND="Unknown"
    fi
    
    CORE_NUM="$(lscpu | grep 'Core(s) per socket' | awk -F: '{print $2}' | xargs)"
    THREADS="$(nproc)"
    THREAD_PER="$(lscpu | grep 'Thread(s) per core' | awk -F: '{print $2}' | xargs)"
    
    # MHz
    MIN_MHZ="$(lscpu | grep 'CPU min MHz' | awk -F: '{print $2}' | xargs | sed 's/\.[0]*$//')"
    MAX_MHZ="$(lscpu | grep 'CPU max MHz' | awk -F: '{print $2}' | xargs | sed 's/\.[0]*$//')"
    CUR_MHZ="$(lscpu | grep 'CPU MHz' | awk -F: '{print $2}' | xargs | sed 's/\.[0]*$//')"
    
    CPU_SCL="$(lscpu | grep 'CPU(s) scaling MHz:' | awk -F: '{print $2}' | xargs | sed 's/\.[0]*$//')"
    
    # Fallback to /sys/devices/system/cpu if lscpu doesn't provide frequency info
    if [[ -z "$MIN_MHZ" && -f "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq" ]]; then
        MIN_MHZ="$(awk '{print int($1/1000)}' /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq 2>/dev/null)"
    fi
    if [[ -z "$MAX_MHZ" && -f "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq" ]]; then
        MAX_MHZ="$(awk '{print int($1/1000)}' /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null)"
    fi
    if [[ -z "$CUR_MHZ" && -f "/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq" ]]; then
        CUR_MHZ="$(awk '{print int($1/1000)}' /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null)"
    fi
    
    # Final fallback if min/max are still empty
    if [[ -z "$MIN_MHZ" ]]; then
        MIN_MHZ="${CUR_MHZ:-Unknown}"
    fi
    if [[ -z "$MAX_MHZ" ]]; then
        MAX_MHZ="${CUR_MHZ:-Unknown}"
    fi
    if [[ -z "$CUR_MHZ" ]]; then
        CUR_MHZ="Unknown"
    fi
    
    # Cache
    L1d="$(lscpu | grep 'L1d' |awk -F: '{print $2}'| xargs |head -1)"
    L1i="$(lscpu | grep 'L1i' |awk -F: '{print $2}'| xargs |head -1)"
    L2="$(lscpu | grep 'L2' |awk -F: '{print $2}'| xargs)"
    L3="$(lscpu | grep 'L3' |awk -F: '{print $2}'| xargs)"
fi

# ASCII art override
ASCII_OVERRIDE=""

while getopts ":a:h" option; do
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
        ascii00="${CYAN}  88                              88  "
        ascii01="${CYAN}  --              ,d              88  "
        ascii02="${CYAN}  88              88              88"
        ascii03="${CYAN}  88 8b,dPPYba, MM88MMM ,adPPYba, 88  "
        ascii04="${CYAN}  88 88P'   \`\"8a  88   a8P_____88 88  "
        ascii05="${CYAN}  88 88       88  88   8PP\"\"\"\"\"\"\" 88  "
        ascii06="${CYAN}  88 88       88  88,  \"8b,   ,aa 88  "
        ascii07="${CYAN}  88 88       88  \"Y888 \`\"Ybbd8\"' 88  "
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
        ascii00="  ${BRIGHT_RED}   =%%%%%#=                                .#%%%%%*..+#%%%%#"
        ascii01="  ${RED}  :#%%*#%%#-+***+:+*=:+++:=*+=+*##*: +*+=+++%%#*%%%+#%%#+++:"
        ascii02="  ${BRIGHT_RED}  *%%*=#%%#%%#%%%*%%##%%%*%%#%%%#%@*+%%@@%*%%%=+%%**##+.    "
        ascii03="  ${RED} =%%##@%#*##*-*##*%%%%%%%%%*#%#+%%%+%%%*--#%%*%%%++%%%:     "
        ascii04="  ${BRIGHT_RED}-%%%==-:.*%%*#%%+*%%%#%%%%=-%%%#**+#%%+  *%%*-=-. =%%%##*.  "
        ascii05="  ${RED}#%%+     =%%%%#-.#%%==%%%=  =%%%%#*%%#. =%%#:     .*#%%%=   "
        ;;
    "arm")
        ascii00=" ${BLUE}⠀⠀⠀⣠⣴⣶⣶⣦⣠⣤⣤⣤⡄⠀⠀⣤⣤⣤⣤⣶⣶⣶⡄⢠⣤⣤⣄⣤⣶⣶⣦⣀⢀⣤⣶⣶⣶⣤⠀⠀"
        ascii01=" ${BLUE}⠀⢰⣿⣿⣿⡿⠿⠿⣿⣿⣿⣿⡇⠀⠀⣿⣿⣿⣿⡿⠿⡿⠁⢸⣿⣿⣿⣿⠿⢿⣿⣿⣿⣿⠿⠿⣿⣿⣿⡄"
        ascii02=" ${BLUE}⢰⣿⣿⣿⠇⠀⠀⠀⠈⣿⣿⣿⡇⠀⠀⣿⣿⣿⠆⠀⠀⠀⠀⢸⣿⣿⣿⠁⠀⠈⣿⣿⣿⡏⠀⠀⢿⣿⣿⡅"
        ascii03=" ${BLUE}⢸⣿⣿⣟⠀⠀⠀⠀⠀⢹⣿⣿⡇⠀⠀⣿⣿⣿⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⣿⣿⣿⠃⠀⠀⢸⣿⣿⡇"
        ascii04=" ${BLUE}⠘⣿⣿⣿⠄⠀⠀⠀⢀⣿⣿⣿⡇⠀⠀⣿⣿⣿⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⠀⢸⣿⣿⡇"
        ascii05=" ${BLUE}⠀⠉⢿⣿⣷⣧⣶⣶⣿⣿⣿⣿⡇⠀⠀⣿⣿⣿⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⠀⢸⣿⣿⡇"
        ascii06=" ${BLUE}⠀⠀⠈⠉⠻⠿⠟⠟⠙⠚⠛⠛⠃⠀⠀⠛⠛⠛⠀⠀⠀⠀⠀⠈⠛⠛⠛⠀⠀⠀⠛⠛⠛⠀⠀⠀⠘⠛⠛⠀"
        ascii07=""
        ascii08=""
        ;;
    "snapdragon")
        ascii00=" ${RED}⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⠠⠀⠀${WHITE}⠤⢀⠀⠀⠀⠀⠀⠀⠀"
        ascii01=" ${RED}⠀⠀⠀⢀⣤⢆⣴⡿⡟⠁⠀⠀⠀⠀⠀⠀${WHITE}⠑⠠⡀⠀⠀⠀"
        ascii02=" ${RED}⠀⠀⣴⡿⣷⣽⢯⣿⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀${WHITE}⠈⠢⠀⠀"
        ascii03=" ${RED}⠀⣼⡿⣽⣻⢾⣟⣷⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WHITE}⠡⠀"
        ascii04=" ${RED}⠠⣿⣽⣻⣽⢿⣞⡿⣾⢷⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WHITE}⢁"
        ascii05=" ${RED}⠀⠛⣾⣽⡾⣯⡿⣽⣯⢿⣻⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀${WHITE}⢸"
        ascii06=" ${RED}⠀⠀⠈⠱⢿⣯⣟⣷⣻⢿⡽⣯⣿⣿⣆⠀⠀⠀⠀⠀⠀${WHITE}⢸"
        ascii07=" ${RED}⢻⣆⣄⠀⠀⠁⠻⣽⣯⣟⣿⣽⣻⣿⣿⡄⠀⠀⠀⠀⠀${WHITE}⡈"
        ascii08=" ${RED}⠀⢻⣯⢿⣧⣦⡄⡈⢳⡿⣞⣷⢿⣿⣿⠃⠀⠀⠀⠀${WHITE}⡐⠀"
        ascii09=" ${RED}⠀⠀⠸⣿⣞⡷⣿⣻⢼⣿⢯⣟⣿⣿⠏⠀⠀⠀${WHITE}⢀⠜⠀⠀"
        ascii10=" ${RED}⠀⠀⠀⠈⠉⠿⣷⣻⣻⣽⣿⡿⠟⠋${WHITE}⡀⢀⠠⠀⠁⠀⠀"
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
# Only show CPU scaling on Linux
if [[ -n "$CPU_SCL" ]]; then
    info10="${COLOR1}${BOLD}CPU(s) scaling MHz: ${RESET}${COLOR}${CPU_SCL}${RESET}" #                           "
else
    info10=""
fi
info11="${COLOR1}${BOLD}L1d:${RESET} ${COLOR}${L1d}${RESET}"
info12="${COLOR1}${BOLD}L1i:${RESET} ${COLOR}${L1i}${RESET}"
info13="${COLOR1}${BOLD}L2:${RESET} ${COLOR}${L2}${RESET}"
info14="${COLOR1}${BOLD}L3:${RESET} ${COLOR}${L3}${RESET}"

# Displayer! (dynamic, padded)
info_vars=( "$info00" "$info01" "$info02" "$info03" "$info04" "$info05" "$info06" "$info07" "$info08" "$info09" "$info10" "$info11" "$info12" "$info13" "$info14" )
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
    echo -e "${info_vars[i]}\t${ascii_vars[i]}"
done

