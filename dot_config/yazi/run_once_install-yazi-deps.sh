#!/bin/bash

# This script is run once by chezmoi to install yazi dependencies.

set -e

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Run the main installation script
"$SCRIPT_DIR/../../run_once_install_yazi_deps.sh"
