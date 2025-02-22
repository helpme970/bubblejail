# bubblejail
This repo is mainly for me so that I don't delete it again by mistake

if you find bugs you are welcome to report them to me.

## What is it
This is a simple bash wrapper for bubblewrap. It simplifies the commands for bubblewrap and adds some new functions, like appimage support.

## Usage
bash bubblejail.sh --stdir --video --audio -p firefox

## Commands
-p | --program    after this the programname or path follows

--debug           show all output written to stdout or stderr
-h | --help       show help (not completed)
--version         show version of bubblejail and bubblewrap
--video           automaticly choose if x11 or wayland socket is shared to the application (needed for programs with gui)
--wayland         share wayland socket to the sandbox
--x11             share x11 socket to the sandbox
--x11 :10         share the x11 socket for the 10th session
--x11-sandbox     create a new x11-session with Xephyr and start the program in it (see lack of x11)
--audio           automaticly share socket of PulseAudio, PipeWire, ALSA or OSS
--gpu             enable hardware acceleration for the sandbox
--cam             enable access to the webcam (v4l or v4l2 must be installed)
--stdir           share important directories which are needed by all programs
--net             enable network in the sandbox
--root            change uid to 0
--nobody          change uid to 65534 which is reserved for the user nobody
--current-user    change the user to the current one
--pass <path>     bind path to the exact same position in the sandbox
--ro-pass         same as --pass but read-only
--dev-pass        same as --pass but with device access
--pass-try        same as --pass but no error if path does not exists
