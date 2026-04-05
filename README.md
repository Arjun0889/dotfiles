# My dotfiles

This directory will contain the dotfiles required to manage the system

# Requirements

Install git, stow using your package manager

For setting up the .zshrc present in this dotfiles add install "jetbrains-mono-nerd-font" font and add it to be used in your terminal profile to use it.

```
$ brew install --cask font-jetbrains-mono-nerd-font
$ brew install zoxide
$ brew install stow
$ brew install jandedobbeleer/oh-my-posh/oh-my-posh
$ brew install yt-dlp
```

# Installation

Checkout to the dotfiles repository you have in your github to your $HOME directory


```
$ git clone https://github.com/Arjun0889/dotfiles.git
$ cd dotfiles
$ stow .
```

Run stow . to get your stow setup started. By running this will create this dotfile setup in your $HOME folder as symlinks.

After stow is started copy any folder you want to place in the dotfiles repo and then remove or rename it from the original location. Make sure the hierarchial structure reamains same as you have it in your $HOME location when copying it to dotfiles folder.

So basically when you add something to folder(like dotfiles) managed by stow in our case it creates a sym-link to that file for folder we stowed in the $HOME location with the same structure. So change the name of file or folder you copy to dotfiles folder. Or you can delete the file in the $HOME location as once you run stow . command it tries to creates a sym link to the $HOME folder and we do not want the conflicts to arise.

Usually add .bak to the file name to have backup of it.

Follow this link for more clarity

```
https://www.youtube.com/watch?v=y6XCebnB9gs
```

# Tmux

tmux keeps terminal sessions alive even after you close the window or lock your screen.
See `TMUX_GUIDE.md` for a full learning guide and Claude Code workflows.

## Install

```bash
brew install tmux
```

## TPM (Plugin Manager) — one-time setup

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## First run

```bash
tmux                        # start tmux
```

Then inside tmux press `Ctrl+b` then `I` (capital i) to install all plugins.
Wait for the install to finish, then press `Enter`.

## Key bindings quick reference

| Action | Key |
|---|---|
| Prefix | `Ctrl+b` |
| Vertical split | `prefix + \|` |
| Horizontal split | `prefix + -` |
| Navigate panes | `prefix + h/j/k/l` |
| Resize panes | `prefix + H/J/K/L` |
| New window | `prefix + c` |
| Next / prev window | `prefix + n / p` |
| Enter copy mode | `prefix + [` or `prefix + Esc` |
| Copy selection | `v` then `y` (in copy mode) |
| Detach session | `prefix + d` |
| Reload config | `prefix + r` |
| Save session | `prefix + Ctrl+s` |
| Restore session | `prefix + Ctrl+r` |

## Shell aliases (from .zshrc)

```bash
ta <name>    # attach to session
tn <name>    # new named session
tl           # list sessions
tk <name>    # kill session
wake         # caffeinate (keep Mac awake on battery for Claude remote)
uncafe       # stop caffeinate
```

