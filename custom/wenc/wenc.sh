#!/usr/bin/env bash

CONFIG_FILE=$HOME/.wencrc
DATA_ENCRYPTED=$HOME/.wenc.encrypted
DATA_PLAIN=$HOME/.wenc.plain

# Get local HOME path.
get_home_path() {
    cd "$HOME"
    cd "$1"
    pwd | sed -r "s#^$HOME/##"
}


# Check encfs is installed.
which encfs &> /dev/null
if [[ "$?" != "0" ]]; then
    sudo apt-get install encfs
fi

# Check is the config file exists.
if [[ ! -f $CONFIG_FILE ]]; then
    echo "Error:"
    echo "Config file $CONFIG_FILE is not pressed"
    echo "Config file should contain a list of directories to be encrypted"
    exit 1
fi

# Check directories
test ! -d $DATA_ENCRYPTED && mkdir -p $DATA_ENCRYPTED
test ! -d $DATA_PLAIN && mkdir -p $DATA_PLAIN

set -x
encfs $DATA_ENCRYPTED $DATA_PLAIN --public
{ set +x; } 2>/dev/null

# Check if Encfs is running
IS_RUNNING_ENCFS=$(ps aux | grep -v "grep" | grep "encfs" | grep "$DATA_PLAIN")               
if [ "$IS_RUNNING_ENCFS" == "" ]
then
    echo ""
    echo "Error:"
    echo "Encfs is not running"
    exit 1
fi

echo

# Processing dirs from config file.
while read DIR
do
    # Test if $DIR is comment.
    if [[ ${DIR:0:1} == "#" ]]; then
        echo "1 comment"
        continue
    fi

    # Prepare absolute address.
    DIR=$(echo "$DIR" | sed -r "s/^\///g")
    DIR=$(echo "$DIR" | sed -r "s/\/$//g")
    DIR="$HOME/${DIR}"
    echo -n " * $DIR"


    # Test if $DIR is symlink.
    if [ -L "$DIR" ]; then
        echo -n " - OK"
        echo
        continue
    fi

    # Test if $DIR is new directory.
    if [[ -d "$DIR" ]]; then
        HOME_PATH=$(get_home_path "$DIR")
        HOME_PATH_MOVE=$(echo "${DATA_PLAIN}/${HOME_PATH}" | sed -r "s/\/[^\/.]*$//g")

        # Prepare directories structure.
        mkdir -p "${DATA_PLAIN}/${HOME_PATH}"
        # Move directory to plain dir for crypt.
        mv "$DIR/" "$HOME_PATH_MOVE"
        # Create symlink on original place,
        ln -s "${DATA_PLAIN}/${HOME_PATH}" "$DIR"

        echo -n " - added new dir"
        echo
        continue
    else
        echo -n " - warning - dir doesn't exist"
    fi

    echo

done < <(LC_ALL=C cat "$CONFIG_FILE") 



