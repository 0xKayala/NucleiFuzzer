#!/bin/bash

# Rename and move NucleiFuzzer.sh file to /usr/bin/nf
sudo cp nucleifuzzer.sh /usr/bin/nf

# Make the NucleiFuzzer file executable
sudo chmod +x /usr/bin/nf

echo "NucleiFuzzer has been installed successfully! Now Enter the command 'nf' to run the tool."
