#!/bin/bash

# Rename the NucleiFuzzer.sh file to NucleiFuzzer
mv NucleiFuzzer.sh nucleifuzzer

# Move the NucleiFuzzer file to /usr/local/bin
sudo mv nucleifuzzer /usr/local/bin/

# Make the NucleiFuzzer file executable
sudo chmod +x /usr/local/bin/nucleifuzzer

# Remove the NucleiFuzzer folder from the home directory
if [ -d "$home_dir/NucleiFuzzer" ]; then
    echo "Removing NucleiFuzzer folder..."
    rm -r "$home_dir/NucleiFuzzer"
fi

echo "NucleiFuzzer has been installed successfully! Now Enter the command 'nucleifuzzer' to run the tool."
