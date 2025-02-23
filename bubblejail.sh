#!/bin/bash

# Exit if no argument is given
if [ $# -eq 0 ]; then
	echo "Bitte übergib den Programmnamen oder den Pfad zur Datei als Parameter"
	exit 1
fi

mkdir -p $HOME/.bubblejail/sandbox
mkdir -p $HOME/.bubblejail/profiles
mkdir -p $HOME/.bubblejail/tmp

cmd=""
#user="user"
user="$USER"
debug=false
xsession=""
virt_home=false
tmp_home=false
for ((i=1 ; i<=$# ; i++ )); do
    arg=${!i}
    case "$arg" in
        -p|--programm) {
            cmd="$cmd --setenv USER $user"
            if [[ $user == "root" ]]; then
                new_home="/root"
                cmd="$cmd --setenv $HOME /root"
            elif [[ $user == "nobody" || $user == "$USER" || $user == "user" ]]; then
                new_home="/home/$user"
                cmd="$cmd --setenv $HOME /home/$user"
            fi

            #cmd="${cmd//"$HOME"/$new_home}"

            cmd="$cmd --setenv XDG_CONFIG_HOME $new_home/.config"

            ((i++))
            program="${!i}"
            if [[ $program == *"/"* ]]; then
                if [ -e "$(readlink -f ${!i})" ]; then
                    program="$(readlink -f ${!i})"
                elif [ ! -e "$(readlink -f ${!i})" ]; then
                    if [ -e "${!i}" ]; then
                        program="${!i}"
                    elif [ ! -e "${!i}" ]; then
                        echo "Program ${!i} does not exist"
                    fi
                fi
                if [ ! -x "$program" ]; then
                    echo "The program is not executable. Change the permissions."
                    exit
                fi
                IFS='/' read -r -a array <<< "$program"
                programname=${array[-1]}
            else
                programname="$program"
            fi
            path="${program//$programname/}"

            if [ $virt_home == true ]; then
                cmd="$cmd --bind ~/.bubblejail/sandbox/$programname $new_home"
            elif [ $tmp_home == true ]; then
                cmd=" --tmpfs $new_home$cmd"
            else
                cmd=" --tmpfs $new_home$cmd"
            fi

            if [[ $programname == *".appimage"* || $programname == *".Appimage"* ]]; then
                if [ -e "$path/squashfs-root" ]; then
                    echo "$path/squashfs-root already exists, lease remove it to continue"
                    exit
                fi
                if [ -d "$program.home" ]; then
                    cmd="$cmd --bind $program.home /home/$user"
                fi
                if [ -d "$program.config" ]; then
                    cmd="$cmd --bind $program.config /home/$user/.config"
                fi
                eval "$program --appimage-extract"
                mv $path/squashfs-root $program

            fi
            cmd="$cmd \"${!i}\""
            ((i++))
            cmd="$cmd ${@:i}"
            break
            break
        };;
        --debug) {
            debug=true
        };;
        -h|--help) {    
            echo "help"
            exit
        };;
        -v|--version) {
            echo "Bubblejail: 1.0"
            bwrap --version
            exit
        };;
        --video) {
            if [[ "$XDG_SESSION_TYPE" == "wayland" && "$WAYLAND_DISPLAY" != "" ]]; then
                cmd="$cmd --setenv WAYLAND_DISPLAY \"$WAYLAND_DISPLAY\" --ro-bind \"$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY\" \"$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY\""
            elif [[ "$XDG_SESSION_TYPE" == "x11" && "$DISPLAY" != "" ]]; then
                if [ "${!i+1}" == *":"* ]; then
                    ((i++))
                    cmd="$cmd --setenv DISPLAY \"${!i}\" --ro-bind /tmp/.X11-unix/X${!i} /tmp/.X11-unix/X${!i}"
                else
                    cmd="$cmd --setenv DISPLAY ":0" --ro-bind /tmp/.X11-unix/X0 /tmp/.X11-unix/X0"
                fi
            fi
        };;
        --wayland) {
            cmd="$cmd --setenv WAYLAND_DISPLAY \"$WAYLAND_DISPLAY\" --ro-bind \"$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY\" \"$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY\""
        };;
        --x11) {
            ((i++))
            if [[ "${!i}" == *":"* ]]; then
                cmd="$cmd --setenv DISPLAY \"${!i}\" --ro-bind /tmp/.X11-unix/X${!i:1} /tmp/.X11-unix/X${!i:1}"
            else
                i=$(($i-1))
                cmd="$cmd --setenv DISPLAY ":0" --ro-bind /tmp/.X11-unix/X0 /tmp/.X11-unix/X0"
            fi
        };;
        --x11-sandbox) {
            for l in {0..50}; do
                if [ ! -e "/tmp/.X11-unix/X$l" ]; then
                    xsession="$l"
                    break
                fi
            done
            cmd="$cmd --setenv DISPLAY ":$xsession" --ro-bind /tmp/.X11-unix/X$xsession /tmp/.X11-unix/X$xsession"
        };;
        --audio) {
            # PulseAudio
            cmd="$cmd --ro-bind \"$XDG_RUNTIME_DIR/pulse/native\" \"$XDG_RUNTIME_DIR/pulse/native\""
            # --ro-bind-try ~/.config/pulse/cookie ~/.config/pulse/cookie
            # ^ only needed for audio over network

            # Pipewire
            #cmd="$cmd --ro-bind-try \"$XDG_RUNTIME_DIR/pipewire-0\" \"$XDG_RUNTIME_DIR/pipewire-0\""

            # ALSA
            #cmd="$cmd --dev-bind /dev/snd /dev/snd"

            # OSS
            #cmd="$cmd --dev-bind /dev/dsp /dev/dsp"
        };;
        --gpu) {
            cmd="$cmd --dev-bind /dev/dri /dev/dri --ro-bind /sys /sys" #/sys/devices/pci0000:00/ /sys/devices/pci0000:00/"
        };;
        --cam|--webcam|--camera) { # v4l
            cmd="$cmd --dev-bind /dev/v4l /dev/v4l --dev-bind /dev/video0 /dev/video0"
        };;
        --stdir) {

            cmd="$cmd --ro-bind /usr /usr --symlink /usr/bin /bin --symlink /usr/lib /lib --symlink /usr/lib64 /lib64 --symlink /usr/sbin /sbin --ro-bind /etc /etc --ro-bind-try /opt /opt --proc /proc --dev /dev --tmpfs /tmp"
        };;
        --net|--share-net|--network) {
            cmd="$cmd --share-net --ro-bind /run/systemd/resolve /run/systemd/resolve"
        };;
        --root) {
            cmd="$cmd --uid 0"
            user="root"
        };;
        --nobody) {
            cmd="$cmd --uid 65534"
            user="nobody"
        };;
        --current-user) {
            user="$USER"
        };;
        --virt-home) {
            virt_home=true
        };;
        --tmp-home) {
            tmp_home=true
        };;
        --pass|--ro-pass|--dev-pass|--pass-try|--ro-pass-try|--dev-pass-try|--bind|--ro-bind|--dev-bind|--bind-try|--ro-bind-try|--dev-bind-try) {
            case $arg in
                --pass|--bind) {
                    cmd="$cmd --bind"
                };;
                --ro-pass|--ro-bind) {
                    cmd="$cmd --ro-bind"
                };;
                --dev-pass|--dev-bind) {
                    cmd="$cmd --dev-bind"
                };;
                --pass-try|--bind-try) {
                    cmd="$cmd --bind-try"
                };;
                --ro-pass-try|--ro-bind-try) {
                    cmd="$cmd --ro-bind-try"
                };;
                --dev-pass-try|--dev-bind-try) {
                    cmd="$cmd --dev-bind-try"
                };;
            esac
            ((i++))
            case "$arg" in
                --pass|--ro-pass|--dev-pass|--bind|--ro-bind|--dev-bind) {
                    if [ -e "$(readlink -f ${!i})" ]; then
                        tmp="$(readlink -f ${!i})"
                    elif [ ! -e "$(readlink -f ${!i})" ]; then
                        if [ -e "${!i}" ]; then
                            tmp="${!i}"
                        elif [ ! -e "${!i}" ]; then
                            echo "File ${!i} does not exist"
                        fi
                    fi
                };;
                *) {
                    tmp="${!i}"
                };;
            esac
            case "$arg" in
                --pass|--ro-pass|--dev-pass|--pass-try|--ro-pass-try|--dev-pass-try) {            
                    cmd="$cmd ${tmp} ${tmp}"
                };;
                --bind|--ro-bind|--dev-bind|--bind-try|--ro-bind-try|--dev-bind-try) {
                    cmd="$cmd ${tmp}"
                    ((i++))
                    cmd="$cmd ${tmp}"
                };;
            esac
        };;
        --tmpfs|--tmp) {
            cmd="$cmd --tmpfs"
            ((i++))
            cmd="$cmd ${!i}"
        };;
        --unshare-user|--unshare-user-try|--unshare-ipc|--unshare-pid|--unshare-net|--unshare-uts|--unshare-cgroup|--unshare-cgroup-try) {
            ::
        };;

        --pass-lang) {
            cmd="$cmd --setenv LANGUAGE $LANGUAGE --setenv LANG $LANG"
        };;
        *) {
            echo "Falsches Argument $arg"
        };;
    esac
done

cmd="bwrap --die-with-parent --as-pid-1 --new-session --unshare-all --clearenv --hostname localhost --setenv XDG_RUNTIME_DIR $XDG_RUNTIME_DIR --setenv XDG_CACHE_HOME \"$new_home/.cache\"$cmd"

if [ $debug = false ]; then
    cmd="$cmd &> /dev/null"
fi

echo "$cmd"

if [ "$xsession" != "" ]; then
    bash bubblejail.sh --stdir --video --pass /tmp/.X11-unix/ --debug --audio -p Xephyr :$xsession -br -fakescreenfps 30 -reset -terminate -once +extension SECURITY +extension GLX +extension XVideo +extension XVideo-MotionCompensation -2button -softCursor -resizeable -title bwrap -no-host-grab -screen 1900x1000 &
    echo lul
    sleep 0.2
    bash bubblejail.sh --stdir --x11 :$xsession --debug -p openbox &
    eval "$cmd"
else
    eval "$cmd"
fi

pkill -P $$