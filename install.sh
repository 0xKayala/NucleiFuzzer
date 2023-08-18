#!/bin/bash

# Clone the NucleiFuzzer repository
git clone https://github.com/0xKayala/NucleiFuzzer.git

# Navigate to the NucleiFuzzer directory
cd NucleiFuzzer

# Make the NucleiFuzzer.sh script executable
chmod +x NucleiFuzzer.sh

# Create a symbolic link without the .sh extension
ln -s NucleiFuzzer.sh NucleiFuzzer

# Move the symbolic link to a directory in the PATH (e.g., /usr/local/bin)
sudo mv NucleiFuzzer /usr/local/bin

echo "Installation completed. You can now use 'NucleiFuzzer' command to run the script."
