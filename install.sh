#!/bin/bash

# Rename and move NucleiFuzzer.sh file to /usr/local/bin/nucleifuzzer
sudo mv NucleiFuzzer.sh /usr/bin/nf

# Make the NucleiFuzzer file executable
sudo chmod u+x /usr/bin/nf

# Remove the NucleiFuzzer folder from the home directory
if [ -d "$home_dir/NucleiFuzzer" ]; then
    echo "Removing NucleiFuzzer folder..."
    rm -r "$home_dir/NucleiFuzzer"
fi

echo "NucleiFuzzer has been installed successfully! Now Enter the command 'nf' to run the tool."
