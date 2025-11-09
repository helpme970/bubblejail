## bubblejail

A lightweight Bash wrapper around **bubblewrap** that simplifies its command line and adds handy features such as AppImage support. This repository is primarily for personal use, but contributions and bug reports are welcome.

---

### What is bubblejail?

✓ Provides short, readable aliases for common bubblewrap options.  
✓ Adds higher‑level helpers (e.g., automatic X11/Wayland handling, audio forwarding, sandboxed home directories).  
✓ Fully compatible with all native bubblewrap arguments.

---

### Dependencies

| Component | Reason |
|-----------|--------|
| **Xephyr** or **Xnest** | X11 host for sandboxed graphical sessions |
| **Openbox** or **bspwm** | Window manager inside the sandbox |
| **bash** | Script interpreter |

---

### Installation

1. Download `bubblejail`.  
2. Make it executable: `chmod +x bubblejail`.  
3. Run it directly or place it in a directory that’s on your `$PATH`.

---

### Basic Usage

```bash
bash bubblejail --stdir --video --net --audio -p firefox
```

The example above launches **Firefox** with shared standard directories, video output, network access, and audio support.

---

### Command‑Line Options

| Short / Long Flag | Description |
|-------------------|-------------|
| `-p, --program` | Followed by the program name or full path to execute. |
| `-d, --debug` | Show all stdout/stderr output for troubleshooting. |
| `-h, --help` | Display help information. |
| `-v, --version` | Print the versions of **bubblejail** and **bubblewrap**. |
| `--video` | Auto‑detect and share the appropriate X11 or Wayland socket for GUI apps. |
| `--wayland` | Explicitly share the Wayland socket. |
| `--x11` | Share the default X11 socket. |
| `--x11 :N` | Share the X11 socket of session *N* (e.g., `:10`). |
| `--x11-sandbox` | Start a fresh X11 session with Xephyr and run the program inside it. |
| `--audio` | Forward PulseAudio, PipeWire, ALSA, or OSS sockets for sound and mic access. |
| `--gpu` | Enable hardware‑accelerated graphics inside the sandbox. |
| `--cam`, `--webcam`, `--camera` | Grant access to the webcam (requires `v4l`/`v4l2`). |
| `--stdir` | Bind essential system directories needed by most programs. |
| `--enable-userns`, `--share-userns` | Allow additional user namespaces. |
| `--share-ipc` | Permit inter‑process communication. |
| `--net`, `--share-net`, `--network` | Enable network connectivity. |
| `--root` | Run the sandbox as UID 0. |
| `--nobody` | Run as UID 65534 (the “nobody” user). |
| `--current-user` | Use the invoking user’s UID (default). |
| `--virt-home` | Use a persistent empty home directory. |
| `--tmp-home` | Use a temporary home that is removed on exit. |
| `--box <name>` | Create an isolated root for multiple programs under *name*. |
| `--pass <SRC>` | Bind *SRC* to the same path inside the sandbox (read‑write). |
| `--ro-pass <SRC>` | Same as `--pass` but read‑only. |
| `--dev-pass <SRC>` | Bind with device permissions. |
| `--pass-try <SRC>` | Like `--pass` but ignore missing paths. |
| `--ro-pass-try <SRC>` | Read‑only version of `--pass-try`. |
| `--dev-pass-try <SRC>` | Device‑access version of `--pass-try`. |
| `--bind <SRC> <DEST>` | Bind *SRC* to *DEST* inside the sandbox. |
| `--ro-bind <SRC> <DEST>` | Read‑only bind. |
| `--dev-bind <SRC> <DEST>` | Device‑access bind. |
| `--bind-try <SRC> <DEST>` | Bind without error on missing source. |
| `--ro-bind-try <SRC> <DEST>` | Read‑only version of `--bind-try`. |
| `--dev-bind-try <SRC> <DEST>` | Device‑access version of `--bind-try`. |
| `--clone`, `--copy` | Copy a file or directory into the sandbox with write permissions. |
| `--tmpfs`, `--tmp` | Create a temporary directory that disappears when the sandbox stops. |
| `--pass-lang` | Propagate the host’s locale settings. |
| `--usb` | Pass all USB drives with write access. |
| `--ro-usb` | Same as `--usb` but read‑only. |
| `--dbus <pattern>` | Grant the program ownership of matching D‑Bus names (e.g., `org.example.portal.*`). |
| `--desktop-portal` | Allow secure access to external files, opening URLs, etc., via the desktop portal. |

> **All** native bubblewrap arguments are also accepted; they are passed through unchanged.

---

### Contributing

- Report bugs via the **Issues** tab.  
- Star the repository if you find it useful.  
- Pull requests are welcome—especially improvements to documentation, new helper flags, or better handling of edge cases.

---
