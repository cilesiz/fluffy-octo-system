function load_default_keyboard
{
# If a keyboard data file does not exist then the user
# prompted to load the standard keyboard data into the 
# $KEYBOARD_FILE, which is defined in the main body of
# the shell script.

clear  # Clear the screen

echo "\nLoad the default keyboard data file? (Y/N): \c"
read REPLY

case $REPLY in
y|Y) :
     ;;
  *) echo "\nSkipping the load of the default keyboard file...\n"
     return
     ;;
esac

cat /dev/null > $KEYBOARD_FILE

echo "\nLoading the Standard Keyboard File...\c"

# Loop through each character in the following list and
# append each character to the $KEYBOARD_FILE file. This
# produces a file with one character on each line.

for CHAR in \` 1 2 3 4 5 6 7 8 9 0 - = \\ q w e r t y u i o \
             p \[ \] a s d f g h j k l \; \' z x c v b n m \, \
             \. \/ \\ \~ \! \@ \# \$ \% \^ \& \* \( \) _ \+ \| \
             Q W E R T Y U I O P \{ \} A S D F G H J K L \: \" \
             Z X C V B N M \< \> \? \| \. 0 1 2 3 4 5 6 7 8 9 \/ \
             \* \- \+
do
     echo "$CHAR" >> $KEYBOARD_FILE
done
echo "\n\n\t...Done...\n"

sleep 1
}

