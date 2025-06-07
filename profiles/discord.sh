#!/bin/bash

# check if script is running as root
if [ "$EUID" == 0 ]
  then echo "Do not run as root"
  exit
fi

audio=""
display=""
if [ $# -gt 0 ]; then
    for ((i=1 ; i<=$# ; i++ )); do
        arg=${!i}
        case "$arg" in
            --no-audio|--disable-audio) {
                audio="aus"
            };;
            --audio|--enable-audio) {
                audio="ein"
            };;
            --x11-sandbox|--disable-x11) {
                display="X11-Sandbox"
            };;
            --x11|--enable-x11) {
                display="Host-diplay"
            };;
            *) {
                echo "Falsche Argumente übergeben"
                exit 1
            };;
        esac
    done
fi

cmd="bash bubblejail.sh --unshare-all --stdir --gpu --enable-userns --virt-home --debug --net --pass $HOME/.config/discord --pass $HOME/.config/Electron --bind $HOME/Downloads/Discord\ Downloads $HOME/Downloads --bind $HOME/.bubblejail/hostname /etc/hostname --chmod 000 /etc/hostname --ro-bind $HOME/.bubblejail/tmp /etc/os-release --ro-bind $HOME/.bubblejail/tmp /etc/shadow --ro-bind $HOME/.bubblejail/tmp /etc/shadow- --ro-bind $HOME/.bubblejail/tmp /usr/lib/os-release" #--setenv SSLKEYLOGFILE $HOME/Downloads/sslkey.log

DIALOG="zenity --title=Tor-Browser-Sandbox"
function abbruchtest {
        if (( $1 == 1 ))
        then
                echo "Abbruch"
                exit 2
        fi
}

if [ "$display" == "" ]; then
    display=$($DIALOG --list --radiolist  \
            --text="Display" \
            --column="" --column="Display"\
            FALSE   "X11-Sandbox" \
            TRUE   "Host-diplay" \
    )
    abbruchtest $?
fi
if [ "$display" == "X11-Sandbox" ]; then
    cmd="$cmd --x11-sandbox"
elif [ "$display" == "Host-diplay" ]; then
    cmd="$cmd --x11"
else
    echo "Fehler"
fi

if [ "$audio" == "" ]; then
    audio=$($DIALOG --list --radiolist  \
            --text="Audio" \
            --column="" --column="Audio"\
            TRUE   "ein" \
            FALSE   "aus" \
    )
    abbruchtest $?
fi
if [ "$audio" == "ein" ]; then
    cmd="$cmd --audio"
elif [ "$audio" == "aus" ]; then
    :::
else
    echo "Fehler"
fi

cmd="$cmd -p discord"
eval "$cmd"