#!/bin/zsh

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <number_of_directories> <number_of_files_per_directory> <location>"
    echo ""
    echo "number_of_directories          Number of directories to create"
    echo "number_of_files_per_directory  Number of files to create in each directory"
    echo "location                       Location where the directories and files will be created"
    exit 1
fi

# Get the number of directories, files, and location from the arguments
num_dirs=$1
num_files=$2
location=$3

# Function to generate a random name
generate_random_name() {
    echo $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
}

# Create directories and files
for ((i = 1; i <= num_dirs; i++)); do
    dir_name=$(generate_random_name)
    dir_path="$location/$dir_name"
    mkdir -p $dir_path
    echo "Created directory: $dir_path"

    for ((j = 1; j <= num_files; j++)); do
        file_name=$(generate_random_name)
        touch $dir_path/$file_name
        echo "Created file: $dir_path/$file_name"
    done
done