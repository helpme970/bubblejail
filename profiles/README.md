# Bubblejail Scripts

Welcome to the **Bubblejail** scripts!  
This repository contains scripts for securely running applications like Discord and the Tor-Browser in an isolated environment.

---

## 💡 Important Notes

- **All profile files must be located in the same directory as `bubblejail.sh`.**
- [`zenity`](https://help.gnome.org/users/zenity/stable/) is required for the GUI support in `discord.sh` and `tor.sh`.

---

## 🚀 How to Run

```sh
bash discord.sh
```
> Replace `discord.sh` with the script you want to run.

---

## ⚙️ Command Line Arguments

### General Options

| Argument                 | Description                                  |
|--------------------------|----------------------------------------------|
| `--no-audio`<br>`--disable-audio`     | Disable access to audio device            |
| `--audio`<br>`--enable-audio`         | Enable access to audio device             |
| `--x11-sandbox`<br>`--disable-x11`    | Run in X11 sandbox mode                   |
| `--x11`<br>`--enable-x11`             | Run on host X11 session                   |

### Only for `tor.sh`

| Argument         | Description                                                        |
|------------------|--------------------------------------------------------------------|
| `--new-session`  | Run without user settings and delete everything after exit         |
| `--settings`     | Run with user settings and keep them after exit                    |

---

## 📦 Dependencies

- [`zenity`](https://help.gnome.org/users/zenity/stable/)
- Bash shell

---

## 📝 Additional Information

- Make sure all profiles and settings files are in the correct directory.
- Options may be combined—see the source code for more details.
