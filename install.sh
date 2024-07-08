#!/bin/bash

# Rename and move NucleiFuzzer.sh file to /usr/bin/nf
sudo mv NucleiFuzzer.sh /usr/bin/nf

# Make the NucleiFuzzer file executable
sudo chmod u+x /usr/bin/nf

echo "NucleiFuzzer has been installed successfully! Now Enter the command 'nf' to run the tool."
