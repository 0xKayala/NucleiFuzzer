#!/bin/bash

# تحديد نوع shell الحالي
current_shell=$(basename "$SHELL")

if [ "$current_shell" = "bash" ]; then
    echo "إضافة المسار إلى .bashrc"
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
    source ~/.bashrc
elif [ "$current_shell" = "zsh" ]; then
    echo "إضافة المسار إلى .zshrc"
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.zshrc
    source ~/.zshrc
else
    echo "نوع shell غير معروف: $current_shell"
    echo "يرجى إضافة المسار يدوياً إلى ملف shell المناسب"
fi

# Rename and move NucleiFuzzer.sh file to /usr/bin/nf
cp NucleiFuzzer.sh $PREFIX/bin/nf

# Make the NucleiFuzzer file executable
chmod +x $PREFIX/bin/nf

echo "NucleiFuzzer has been installed successfully! Now Enter the command 'nf' to run the tool."
