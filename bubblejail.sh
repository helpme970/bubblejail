#!/bin/bash

# Exit if no argument is given
if [ $# -eq 0 ]; then
	echo "Bitte übergib den Programmnamen oder den Pfad zur Datei als Parameter"
	exit 1
fi

mkdir -p $HOME/.bubblejail/sandbox
#mkdir -p $HOME/.bubblejail/profiles
#mkdir -p $HOME/.bubblejail/tmp

if [[ ! -f $HOME/.bubblejail/tmp ]]; then
    echo "" > $HOME/.bubblejail/tmp
fi
if [[ ! -f $HOME/.bubblejail/hostname ]]; then
    echo "" > $HOME/.bubblejail/hostname
fi
if [[ ! -f $HOME/.bubblejail/os-release ]]; then
    echo "" > $HOME/.bubblejail/os-release
fi
if [[ ! -f $HOME/.bubblejail/shadow ]]; then
    echo "" > $HOME/.bubblejail/shadow
fi
if [[ ! -f $HOME/.bubblejail/shadow- ]]; then
    echo "" > $HOME/.bubblejail/shadow-
fi

cmd=" --unshare-net --unshare-ipc"
#user="user"
user="$USER"
debug=false
xsession=""
virt_home=""
tmp_home=""
box=""
userns=false
clone=""

for ((i=1 ; i<=$# ; i++ )); do
    arg=${!i}
    case "$arg" in
        -p|--programm) {
            cmd="$cmd --setenv USER $user"
            if [[ $user == "root" ]]; then
                new_home="/root"
                cmd="$cmd --setenv HOME /root"
            elif [[ $user == "nobody" || $user == "$USER" || $user == "user" ]]; then
                new_home="/home/$user"
                cmd="$cmd --setenv HOME /home/$user"
            fi

            cmd="$cmd --setenv XDG_CONFIG_HOME $new_home/.config"

            ((i++))
            program="${!i}"
            if [ "$box" != "" ]; then
                box2="${box//--bind /}"
                box2="${box2// \//}"
                program2="$box2${!i}"
            else
                program2="$program"
            fi
            if [[ "$program2" == *"/"* || "$program2" == *"."* ]]; then
                if [ -e "$(readlink -f "${program2}")" ]; then
                    program2="$(readlink -f "${program2}")"
                elif [ -e "$(readlink -f "${!i}")" ]; then
                    program2="${!i}"
                else
                    echo "Program ${program2} does not exist"
                    exit 1
                fi
                if [ ! -x "$program2" ]; then
                    echo "$program2 is not executable. Change the permissions."
                    exit 1
                fi
                if [[ "${program:$((${#program}-1)):1}" == "/" ]]; then
                    program="${program[-1]}"
                fi
                if [[ "$program" == *"/"* ]]; then
                    IFS='/' read -r -a array <<< "$program"
                    programname=${array[-1]}
                fi
                path="${program//$programname/}"
                #if [[ "$program" == *"."* ]]; then
                #    IFS='.' read -r -a array <<< "${!i}"
                #    for ((i=0; i < ${#array}; i++)); do
                #        echo ${array[i]}
                #        programname="${programname}.${array[i]}"
                #    done
                #fi
            else
                programname="$program"
            fi

            if [ $userns = false ]; then
                cmd="$cmd --disable-userns"
            fi

            if [ "$virt_home" != "" ]; then
                mkdir -p $HOME/.bubblejail/sandbox/$programname$new_home
                cmd=" --bind ~/.bubblejail/sandbox/$programname /$cmd" #--bind ~/.bubblejail/sandbox/$programname$new_home $new_home$cmd"
            elif [ "$tmp_home" != "" ]; then
                cmd=" --tmpfs $new_home$cmd"
            elif [ "$box" != "" ]; then
                cmd=" $box$cmd"
            else
                cmd=" --tmpfs $new_home$cmd"
            fi

            if [ ${#copy} -gt 0 ]; then
                IFS=';' read -ra copy <<< "$copy"
                for l in "${copy[@]}"; do
                    if [ -e "$HOME/.bubblejail/sandbox/$programname$l" ]; then
                        echo "$HOME/.bubblejail/sandbox/$programname$l already exists"
                        #exit
                    elif [ ! -e "$HOME/.bubblejail/sandbox/$programname$l" ]; then
                        echo "$HOME/.bubblejail/sandbox/$programname$l created"
                        if [ -d "$l" ]; then
                            if [ "${l:$((${#l}-1)):1}" == "/" ]; then
                                l=${l:$((${#l}-1))}
                            fi
                            IFS='/' read -r -a array <<< "$l"
                            array="${array[-1]}"
                            l2="${l//$array/ }"
                            mkdir -p $HOME/.bubblejail/sandbox/$programname$l2
                            #mkdir -p $HOME/.bubblejail/sandbox/$programname$l
                            cp -R "$l" "$HOME/.bubblejail/sandbox/$programname$l"
                            echo cp1
                        elif [ -f "$l" ]; then
                            IFS='/' read -r -a array <<< "$l"
                            array="${array[-1]}"
                            l2="${l//$array/ }"
                            mkdir -p $HOME/.bubblejail/sandbox/$programname$l2
                            cp "$l" "$HOME/.bubblejail/sandbox/$programname$l"
                            echo cp2
                        else
                            echo fehler
                            exit 1
                        fi
                    else
                        echo fehler
                        exit 1
                    fi
                    old="$l"
                    l="$HOME/.bubblejail/sandbox/$programname$l"
                    cmd="$cmd --bind \"$l\" \"$old\""
                done
            fi

            if [[ $programname = *".appimage"* || $programname = *".Appimage"* || $programname = *".AppImage"* ]]; then
                if [ -e "$path/squashfs-root" ]; then
                    echo "$path/squashfs-root already exists, please remove it to continue"
                    exit 1
                fi
                if [ -d "$program.home" ]; then
                    cmd="$cmd --bind $program.home /home/$user"
                fi
                if [ -d "$program.config" ]; then
                    cmd="$cmd --bind $program.config /home/$user/.config"
                fi
                eval "$path$programname --appimage-extract" > /dev/null
                #mv "${path}squashfs-root" "$program-sandboxed"
                mv "${pwd}squashfs-root" "$program-sandboxed"
                debug=true
                cmd="$cmd --bind \"\${path//\$0/}\" \"\${path//\$0/}\" ./AppRun"
            else
                cmd="$cmd \"$program\""
            fi

            ((i++))
            
            for ((l=$i; l<=$#; l++)); do
                a="${!l}"
                #a="${a// /\\ }"
                #a="${a//(/\\(}"
                #a="${a//)/\\)}"
                #a="${a//\'/\\\'}"
                cmd="$cmd '$a'"
            done
            #cmd="$cmd ${@:i}"
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
            #cmd="$cmd --setenv DISPLAY ":0" --ro-bind /tmp/.X11-unix/X$xsession /tmp/.X11-unix/X0"
            cmd="$cmd --setenv DISPLAY ":$xsession" --ro-bind /tmp/.X11-unix/X$xsession /tmp/.X11-unix/X$xsession"
        };;
        --audio) {
            # PulseAudio
            cmd="$cmd --ro-bind-try \"$XDG_RUNTIME_DIR/pulse/native\" \"$XDG_RUNTIME_DIR/pulse/native\""
            # --ro-bind-try ~/.config/pulse/cookie ~/.config/pulse/cookie
            # ^ only needed for audio over network

            # Pipewire
            cmd="$cmd --ro-bind-try \"$XDG_RUNTIME_DIR/pipewire-0\" \"$XDG_RUNTIME_DIR/pipewire-0\""

            # ALSA
            cmd="$cmd --dev-bind-try /dev/snd /dev/snd"

            # OSS
            cmd="$cmd --dev-bind-try /dev/dsp /dev/dsp"
        };;
        --gpu) {
            cmd="$cmd --dev-bind /dev/dri /dev/dri --ro-bind /sys /sys" #/sys/devices/pci0000:00/ /sys/devices/pci0000:00/"
        };;
        --cam|--webcam|--camera) { # v4l
            cmd="$cmd --dev-bind /dev/v4l /dev/v4l --dev-bind /dev/video0 /dev/video0"
        };;
        --stdir) {
            cmd="$cmd --ro-bind /usr /usr --symlink /usr/bin /bin --symlink /usr/lib /lib --symlink /usr/lib64 /lib64 --symlink /usr/sbin /sbin --ro-bind /etc /etc --ro-bind-try /opt /opt --proc /proc --dev /dev --tmpfs /tmp --bind $HOME/.bubblejail/hostname /etc/hostname --chmod 000 /etc/hostname --bind $HOME/.bubblejail/os-release /etc/os-release --chmod 000 /etc/os-release --bind $HOME/.bubblejail/tmp /etc/shadow --chmod 000 /etc/shadow --bind $HOME/.bubblejail/tmp /etc/shadow- --chmod 000 /etc/shadow- --bind $HOME/.bubblejail/tmp /usr/lib/os-release --chmod 000 /usr/lib/os-release --bind $HOME/.bubblejail/tmp /var/lib/dbus/machine-id --chmod 000 /var/lib/dbus/machine-id --bind $HOME/.bubblejail/tmp /etc/machine-id --chmod 000 /etc/machine-id --tmpfs /usr/src --chmod 000 /usr/src --tmpfs /usr/lib/modules --chmod 000 /usr/lib/modules" # --tmpfs /lib/modules --chmod 000 /lib/modules --tmpfs /boot --chmod 000 /boot
        };;
        --enable-userns) {
            userns=true           
        };;
        --net|--share-net|--network) {
            cmd="${cmd//--unshare-net/}"
            cmd="$cmd --ro-bind-try /run/systemd/resolve /run/systemd/resolve"
            #cmd="$cmd --share-net --ro-bind-try /run/systemd/resolve /run/systemd/resolve"
        };;
        --share-ipc) {
            cmd="${cmd//--unshare-ipc/}"
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
            virt_home=" "
        };;
        --tmp-home) {
            tmp_home=" "
        };;
        --box) {
            ((i++))
            if [ -e "$HOME/.bubblejail/sandbox/${!i}" ]; then
                tmp="${!i}"
            elif [ ! -e "$HOME/.bubblejail/sandbox/${!i}" ]; then
                mkdir -p "$HOME/.bubblejail/sandbox/${!i}"
                echo "Created new box ${!i}"
            fi
            box="--bind $HOME/.bubblejail/sandbox/${!i} /"
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

                    tmp="$(readlink -f "${!i}")"
                    #tmp="${tmp// /\\ }"
                    #tmp="${tmp//(/\\(}"
                    #tmp="${tmp//)/\\)}"
                    if [ -e "$tmp" ]; then
                        :
                    elif [ ! -e "$(readlink -f ${!i})" ]; then
                        if [ -e "${!i}" ]; then
                            tmp="${!i}"
                        elif [ ! -e "${!i}" ]; then
                            echo "File ${!i} does not exist"
                            exit 1
                        fi
                    fi
                };;
                *) {
                    tmp="${!i}"
                };;
            esac
            case "$arg" in
                --pass|--ro-pass|--dev-pass|--pass-try|--ro-pass-try|--dev-pass-try) {            
                    cmd="$cmd \"${tmp}\" \"${tmp}\""
                };;
                --bind|--ro-bind|--dev-bind|--bind-try|--ro-bind-try|--dev-bind-try) {
                    cmd="$cmd \"${tmp}\""
                    ((i++))
                    cmd="$cmd \"${!i}\""
                };;
            esac
        };;
        --clone|--copy) {
            ((i++))
            if [ -e "$(readlink -f ${!i})" ]; then
                tmp="$(readlink -f ${!i})"
            elif [ ! -e "$(readlink -f ${!i})" ]; then
                if [ -e "${!i}" ]; then
                    tmp="${!i}"
                elif [ ! -e "${!i}" ]; then
                    echo "File ${!i} does not exist"
                    exit 1
                fi
            fi
            copy="$copy${tmp};"
        };;
        --tmpfs|--tmp) {
            cmd="$cmd --tmpfs"
            ((i++))
            cmd="$cmd ${!i}"
        };;
        --pass-lang) {
            cmd="$cmd --setenv LANGUAGE $LANGUAGE --setenv LANG $LANG"
        };;
        --usb) {
            cmd="$cmd --bind /media /media --bind /mnt /mnt"
        };;
        --ro-usb) {
            cmd="$cmd --ro-bind /media /media --ro-bind /mnt /mnt"
        };;

        ## bwrap parameter
        # do nothing
        --unshare-user|--unshare-user-try|--unshare-ipc|--unshare-pid|--unshare-net|--unshare-uts|--unshare-cgroup|--unshare-cgroup-try|--unshare-all|--clearenv|--new-session|--die-with-parent|--as-pid-1) {
            :
        };;

        # no parameter
        --disable-userns|--assert-userns-disabled) {
            cmd="$cmd $arg"
        };;
        
        # one parameter
        --args|--argv0|--userns|--userns2|--pidns|--uid|--gid|--hostname|--chdir|--unsetenv|--lock-file|--sync-fd|--remount-ro|--exec-label|--file-label|--proc|--dev|--tmpfs|--mqueue|--dir|--seccomp|--add-seccomp-fd|--block-fd|--userns-block-fd|--info-fd|--json-status-fd|--cap-add|--cap-drop|--perms|--size) {
            cmd="$cmd $arg"
            ((i++))
            cmd="$cmd ${!i}"
        };;

        # two parameter
        --setenv|--bind-fd|--ro-bind-fd|--file|--bind-data|--ro-bind-data|--symlink|--chmod) {
            cmd="$cmd $arg"
            ((i++))
            cmd="$cmd ${!i}"
            ((i++))
            cmd="$cmd ${!i}"
        };;

        *) {
            echo "Falsches Argument $arg"
            exit 1
        };;
    esac
done

cmd="bwrap --die-with-parent --as-pid-1 --unshare-user --unshare-cgroup --unshare-pid --unshare-uts --new-session --clearenv --hostname localhost --setenv XDG_RUNTIME_DIR $XDG_RUNTIME_DIR --setenv XDG_CACHE_HOME \"$new_home/.cache\"$cmd"

if [[ $debug == false ]]; then
    cmd="$cmd &> /dev/null"
fi

echo "$cmd"

final_cmd="#if [ -x \"\$\(command -v Xephyr\)\" ]; then
    #echo noixe
bash bubblejail.sh --stdir --video --gpu --pass /tmp/.X11-unix/ --debug --audio -p Xephyr :$xsession -br -fakescreenfps 30 -reset -terminate -once +extension SECURITY +extension GLX +extension XVideo +extension XVideo-MotionCompensation -2button -softCursor -resizeable -title \"$programname\" -no-host-grab -screen 1920x1000 &
#elif [ -x \"\$\(command -v Xnest\)\" ]; then
    #bash bubblejail.sh --stdir --video --pass /tmp/.X11-unix/ --debug --audio -p Xnest -geometry 1900x1000 -name $programname :\$xsession &
#bash bubblejail.sh --stdir --video --pass /tmp/.X11-unix/ --debug --audio -p Xpra &
#else:
    #echo \"No X11 Host found\"
    #exit 1
#fi

#sleep 0.2
sleep 0.2

bash bubblejail.sh --stdir --x11 :$xsession --gpu --debug -p openbox &
#bash bubblejail.sh --stdir --x11 :$xsession --gpu --debug -p bspwm &
#bash bubblejail.sh --stdir --setenv DISPLAY ":0" --ro-bind /tmp/.X11-unix/X$xsession /tmp/.X11-unix/X0 --gpu --debug -p openbox &
sleep 0.2
eval \"$cmd\""

{ # try
    if [[ $programname == *".appimage"* || $programname == *".Appimage"* || $programname == *".AppImage"* ]]; then
        if [ "$xsession" != "" ]; then
            echo "#!/bin/bash
    path=\"\$(readlink -f \$0)\"
    eval $final_cmd" > $program-sandboxed/run-sandboxed.bash
        else
            echo "#!/bin/bash
    path=\"\$(readlink -f \$0)\"
    eval '$cmd'" > $program-sandboxed/run-sandboxed.bash
        fi
    else
        if [ "$xsession" != "" ]; then
            eval "$final_cmd"
        else
            eval "$cmd"
        fi
    fi
} || { # catch
    pkill -P $$
}

pkill -P $$
