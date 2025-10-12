# My dotfiles

This directory will contain the dotfiles required to manage the system

# Requirements

Install git, stow using your package manager

# Installation

Checkout to the dotfiles repository you have in your github to your $HOME directory


```
$ git clone https://github.com/Arjun0889/dotfiles.git
$ cd dotfiles
```

Run stow . to get your stow setup started

```
$ stow .
```
After stow is started copy any folder you want to place in the dotfiles repo and then remove or rename it from the original location. Make sure the hierarchial structure reamains same as you have it in your $HOME location when copying it to dotfiles folder.

So basically when you add something to folder(like dotfiles) managed by stow in our case it creates a sym-link to that file for folder we stowed in the $HOME location with the same structure. So change the name of file or folder you copy to dotfiles folder. Or you can delete the file in the $HOME location as once you run stow . command it tries to creates a sym link to the $HOME folder and we do not want the conflicts to arise.

Usually add .bak to the file name to have backup of it.

Follow this link for more clarity

```
https://www.youtube.com/watch?v=y6XCebnB9gs
```
