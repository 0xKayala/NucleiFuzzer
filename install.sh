#!/bin/bash

# Rename the NucleiFuzzer.sh file to NucleiFuzzer
mv NucleiFuzzer.sh nucleifuzzer

# Move the NucleiFuzzer file to /usr/local/bin
sudo mv nucleifuzzer /usr/local/bin/

# Make the NucleiFuzzer file executable
sudo chmod +x /usr/local/bin/nucleifuzzer

echo "NucleiFuzzer has been installed successfully! Now Enter 'nucleifuzzer' to run the tool."
