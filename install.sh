#!/bin/bash

# get the current shell type
current_shell=$(basename "$SHELL")

if [ "$current_shell" = "bash" ]; then
    echo " add path to .bashrc"
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
    source ~/.bashrc
elif [ "$current_shell" = "zsh" ]; then
    echo " add path to .zshrc"
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.zshrc
    source ~/.zshrc
else
    echo "unknown shell type: $current_shell"
    echo "place add the path manually to the shell file"
fi

# Rename and move NucleiFuzzer.sh file to /usr/bin/nf
cp NucleiFuzzer.sh $PREFIX/bin/nf

# Make the NucleiFuzzer file executable
chmod +x $PREFIX/bin/nf

echo "NucleiFuzzer has been installed successfully! Now Enter the command 'nf' to run the tool."
