#!/bin/bash

# check if script is running as root
if [ "$EUID" == 0 ]
  then echo "Do not run as root"
  exit
fi

audio=""
display=""
session=""
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
                display="Host-display"
            };;
            --new-session) {
                session="Neue Session"
            };;
            --settings) {
                session="Einstellungen behalten"
            };;
            *) {
                echo "Falsche Argumente übergeben"
                exit 1
            };;
        esac
    done
fi

cmd="bash bubblejail.sh --debug --stdir --audio --gpu --net --pass-lang --enable-userns"

function abbruchtest {
        if (( $1 == 1 ))
        then
                echo "Abbruch"
                exit 2
        fi
}

DIALOG="zenity --title=Tor-Browser-Sandbox"

if [ "$session" == "" ]; then
    session=$($DIALOG --list --radiolist  \
            --text="Session auswählen." \
            --column="" --column="Session"\
            FALSE   "Neue Session" \
            TRUE   "Einstellungen behalten" \
    )
    abbruchtest $?
fi
if [[ $session == "Neue Session" ]]; then
    cmd="$cmd --ro-pass ./tor-browser/ --tmp $HOME/Downloads/tor-browser/Browser/TorBrowser/Data"
elif [[ $session == "Einstellungen behalten" ]]; then
    cmd="$cmd --ro-pass ./tor-browser/ --clone $HOME/Downloads/tor-browser/Browser/TorBrowser/Data" #profiles.ini --clone $HOME/Downloads/tor-browser/Browser/TorBrowser/Data/Browser/profile.default"
else
    echo "Fehler"
fi

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
    :
else
    echo "Fehler"
fi

#display=$($DIALOG --entry \
#--text="Enter Display Number:" \
#--entry-text "0")
#abbruchtest $?

#if [[ ! display == *":"* ]]; then
#        display=":$display"
#fi

cmd="$cmd --pass $PWD/tor-browser/Browser/Downloads -p $PWD/tor-browser/Browser/start-tor-browser"
#cmd="$cmd -p bash"
echo "$cmd"
eval $cmd
