#!/bin/bash

# This script interactively installs either 'brokefetch.sh' or 'brokefetch_EDGE.sh'
# from the current directory to /usr/bin. It prompts the user for choices.

# --- Step 1: Identify available source files ---

available_scripts=()
if [ -f "cpuinfo.sh" ]; then
    available_scripts+=("cpuinfo.sh")
fi

# Exit if no source files are found
if [ ${#available_scripts[@]} -eq 0 ]; then
    echo "Error: cpuinfo.sh was not found in the current directory."
    exit 1
fi

# --- Step 2: Prompt user for choice if multiple scripts are found ---

source_file=""
if [ ${#available_scripts[@]} -eq 1 ]; then
    source_file="${available_scripts[0]}"
    echo "Found '${source_file}'. This script will be installed."
else
    echo "Multiple brokefetch scripts found. Please choose one to install:"
    select choice in "${available_scripts[@]}"; do
        if [ -n "$choice" ]; then
            source_file="$choice"
            break
        else
            echo "Invalid choice. Please select a number from the list."
        fi
    done
fi

# --- Step 3: Check for existing installation and prompt for overwrite/remove ---

# Check if an old version of brokefetch exists
if [ -f "/usr/bin/cpuinfo" ]; then
    echo "An existing 'cpuinfo' script was found at /usr/bin/cpuinfo."
    
    # Prompt the user to remove or replace
    while true; do
        read -p "Do you want to (r)eplace it or (x) to remove it first? (r/x) " action
        case "$action" in
            [Rr]* ) 
                echo "Replacing existing cpuinfo script."
                break
                ;;
            [Xx]* )
                echo "Removing old version before installation."
                sudo rm /usr/bin/cpuinfo
                break
                ;;
            * ) 
                echo "Invalid input. Please enter 'r' or 'x'."
                ;;
        esac
    done
fi

# --- Step 4: Perform the installation ---

echo "Installing '$source_file' to /usr/bin/cpuinfo..."

# Copy the chosen file to /usr/bin
sudo cp "$source_file" /usr/bin/cpuinfo

# Make the new file executable
sudo chmod +x /usr/bin/cpuinfo

# --- Step 5: Verify installation and provide success message ---

if [ -f "/usr/bin/cpuinfo" ]; then
    echo "Success! '$source_file' is now installed as 'cpuinfo'."
    echo "You can run it from any directory by typing 'cpuinfo'."
else
    echo "An error occurred during installation."
    exit 1
fi

exit 0
