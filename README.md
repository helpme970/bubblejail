# bubblejail
This repo is mainly for me so that I don't delete it again by mistake

if you find bugs you are welcome to report them to me.

## What is it
This is a simple bash wrapper for bubblewrap. It simplifies the commands for bubblewrap and adds some new functions, like appimage support.

## What is needed
Xephyr and openbox must be installed for usahe of the x11 sandbox as well as bash, because the entire script is written in it.

## Usage
bash bubblejail.sh --stdir --video --audio -p firefox

## Commands
```
-p | --program    	              after this the programname or path follows
--debug           	              show all output written to stdout or stderr
-h | --help       	              show help (not completed)
-v | --version                  	show version of bubblejail and bubblewrap
--video                         	automaticly choose if x11 or wayland socket is shared to the application (needed for programs with gui)
--wayland                       	share wayland socket to the sandbox
--x11                           	share x11 socket to the sandbox
--x11 :10                        	share the x11 socket for the 10th session
--x11-sandbox     	              create a new x11-session with Xephyr and start the program in it (see lack of x11)
--audio           	              automaticly share socket of PulseAudio, PipeWire, ALSA or OSS Socket to allow audio playback and microphone access
--gpu             	              enable hardware acceleration for the sandbox
--cam | --webcam | --camera       enable access to the webcam (v4l or v4l2 must be installed)
--stdir           	              share important directories which are needed by all programs
--enable-userns	  	              allow further namespaces in the sandbox environment
--net | --share-net | --network   enable network access
--root            	              change uid to 0
--nobody          	              change uid to 65534 which is reserved for the user nobody
--current-user    	              change the user to the current one
--virt-home		  	                run the program in an empty home which is permanently saved
--tmp-home		  	                create empty home which is deleted after closing the program
--pass SRC	     	                bind path to the exact same position in the sandbox
--ro-pass         	              same as --pass but read-only
--dev-pass        	              same as --pass but with device access
--pass-try        	              same as --pass but no error if path does not exists
--ro-pass-try     	              same as --pass-try but read-only
--dev-pass-try    	              same as --pass-try but with device access
--bind SRC DEST	 	                bind path to the exact same position in the sandbox
--ro-bind SRC DEST                same as --bind but read-only
--dev-bind SRC DEST               same as --bind but with device access
--bind-try SRC DEST               same as --bind but no error if path does not exists
--ro-bind-try SRC DEST            same as --bind-try but read-only
--ro-bind-try SRC DEST            same as --bind-try but with device access
--clone | --copy  	              copy the file/directory into the sandbox with write permissions
--tmpfs | --tmp  	                create temporary folder which is deleted after closing the program
--pass-lang		  	                pass the language into the sandbox

+++++++++++++++++++++++++++++++++++++++++

All bubblewrap command line arguments are supported by bubblejail

+++++++++++++++++++++++++++++++++++++++++
```
