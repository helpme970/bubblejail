# bubblejail
This repo is mainly for me so that I don't delete it again by mistake

if you find bugs you are welcome to report them to me.

## What is it
This is a simple bash wrapper for bubblewrap. It simplifies the commands for bubblewrap and adds some new functions, like appimage support.

## Dependencies
Xephyr or Xnest as x11 host

openbox or bspwm as window manager

bash 

## Usage
```
bash bubblejail.sh --stdir --video --net --audio -p firefox
```

## Commands
```
-p | --program    	              after this the programname or path follows
-d | --debug           	          show all output written to stdout or stderr
-h | --help       	              show help (not completed)
-v | --version                    show version of bubblejail and bubblewrap
--video                           automaticly choose if x11 or wayland socket is shared to the application (needed for programs with gui)
--wayland                         share wayland socket to the sandbox
--x11                             share x11 socket to the sandbox
--x11 :10                         share the x11 socket for the 10th session
--x11-sandbox     	              create a new x11-session with Xephyr and start the program in it (see lack of x11)
--audio           	              automaticly share socket of PulseAudio, PipeWire, ALSA or OSS to allow audio playback and microphone access
--gpu             	              enable hardware acceleration for the sandbox
--cam | --webcam | --camera       enable access to the webcam (v4l or v4l2 must be installed)
--stdir           	              share important directories which are needed by all programs
--enable-userns | --share-userns  allow further namespaces in the sandbox environment
--share-ipc                       grant access to ipc (inter process communication)
--net | --share-net | --network   enable network access
--root            	              change uid to 0
--nobody          	              change uid to 65534 which is reserved for the user nobody
--current-user    	              change the user to the current one (default)
--virt-home		  	              run the program in an empty home which is permanently saved
--tmp-home		  	              create empty home which is deleted after closing the program
--box boxname                     create new sandbox called boxname to divert the root directorys of multiple programs
--pass SRC	     	              bind src to the exact same position in the sandbox
--ro-pass         	              same as --pass but read-only
--dev-pass        	              same as --pass but with device access
--pass-try        	              same as --pass but no error if path does not exists
--ro-pass-try     	              same as --pass-try but read-only
--dev-pass-try    	              same as --pass-try but with device access
--bind SRC DEST	 	              bind src to dest in the sandbox
--ro-bind SRC DEST                same as --bind but read-only
--dev-bind SRC DEST               same as --bind but with device access
--bind-try SRC DEST               same as --bind but no error if path does not exists
--ro-bind-try SRC DEST            same as --bind-try but read-only
--ro-bind-try SRC DEST            same as --bind-try but with device access
--clone | --copy  	              copy the file/directory into the sandbox at the sa,e location with write permissions
--tmpfs | --tmp  	              create temporary folder which is deleted after closing the sadnbox
--pass-lang		  	              pass the language into the sandbox
--usb                             pass all usb-drives with write access
--ro-usb                          same as --usb but read only
--dbus org.example.portal.*       grant the program the right to own dbus org.example.portal.*
--desktop-portal                  program can access files outside the sandbox securely (without exposing all files), open urls in browser, ...

+++++++++++++++++++++++++++++++++++++++++

All bubblewrap command line arguments are supported by bubblejail

+++++++++++++++++++++++++++++++++++++++++
```
