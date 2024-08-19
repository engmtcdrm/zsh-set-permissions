#!/bin/zsh

# Function to set permissions for files and directories
# Usage: set_permissions <quiet> <dir> <ref_name> [<dir_perm> <file_perm> <exe_file_perm> <exe_exts>]
# Arguments:
#   quiet: If set to "false", the function will print the progress of the operation
#   dir: The directory to set permissions for
#   ref_name: The name of the reference file used to track changes
#   dir_perm: The permission to set for directories (default: 2755)
#   file_perm: The permission to set for files (default: 644)
#   exe_file_perm: The permission to set for executable files (default: 755)
#   exe_exts: A pipe-separated list of file extensions that are considered executable (default: "*.awk|*.bash|*.csh|*.fish|*.groovy|*.js|*.ksh|*.lua|*.php|*.pl|*.pm|*.py|*.r|*.rb|*.sh|*.tcl|*.tcsh|*.zsh")
set_permissions() {
    local esc_seq="\033[1K\r"
    local green="\033[0;32m"
    local reset="\033[0m"

    local quiet=$1
    local dir=$2
    local ref_name=$3
    local dir_perm=${4:-2755}
    local file_perm=${5:-644}
    local exe_file_perm=${6:-755}
    local exe_exts=${7:-"*.awk|*.bash|*.csh|*.fish|*.groovy|*.js|*.ksh|*.lua|*.php|*.pl|*.pm|*.py|*.r|*.rb|*.sh|*.tcl|*.tcsh|*.zsh"}

    dir="${dir/#\~/$HOME}" # Expand ~ to the home directory
    dir="${dir/#./$(pwd)}" # Expand . to the current directory

    # Determine the reference file location
    if [[ "$ref_name" == */* ]]; then
        # ref_name contains a path
        local ref_dir="${ref_name%/*}"
        local ref_base="${ref_name##*/}"
        local ref_file="${ref_dir}/.${ref_base}_last_permission_check"
    else
        # ref_name does not contain a path, place it in the home directory
        local ref_file="${HOME}/.${ref_name}_last_permission_check"
    fi

    if [[ "$quiet" == "false" ]]; then
        echo -ne "Setting permissions for files and directories in ${green}${dir}${reset}..."
    fi

    # Check if the reference file exists
    if [ -e "$ref_file" ]; then
        # Get the last change time of the reference file
        reference_time=$(stat -c %Y "$ref_file")
    else
        # Create the reference file if it does not exist using the Unix epoch time
        touch -t 197001010000.00 "$ref_file"
    fi

    # Find all directories and files changed since the reference time
    find "$dir" -type d -cnewer "$ref_file" -print | while read dir_item; do
        if [[ ":PATH:" == *":$dir_item:"* ]] || [[ "$dir_item" == *"/.git" ]] || [[ "$dir_name" == *"/logs" ]]; then
            continue
        fi

        # echo "Directory changed: $dir_item"
        chmod $dir_perm "$dir_item"
    done

    find "$dir" -type f -cnewer "$ref_file" -print | while read file_item; do
        # echo "File changed: $file_item"
        filename=$(basename "$file_item")
        ext="${filename##*.}"

        # Check if the directory containing the file is in PATH
        if [[ ":$PATH:" == *":$(dirname "$file_item"):"* ]]; then
            continue
        fi

        # If file has no extension, assume it is executable
        if [[ "$filename" == "$ext" ]]; then
            chmod $exe_file_perm "$file_item"
            continue
        fi

        # Use eval to expand the string into separate patterns
        eval "
        case \"$file_item\" in
            $exe_exts)
                chmod $exe_file_perm \"$file_item\"
                ;;
            *)
                chmod $file_perm \"$file_item\"
                ;;
        esac
        "
    done

    if [[ "$quiet" == false ]]; then
        echo -e "${esc_seq}Setting permissions for files and directories in ${green}${dir}${reset}...done"
    fi

    # Update the reference file's timestamp
    touch "$ref_file"
}