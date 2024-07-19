# Dotfiles

Dotfiles is simply put a collection of different configuration files I want to have quick
access to.

## Prerequisites

~~No installation needed in most POSIX style systems. The only requirement to
apply the different configurations is to make sure to have GNU Stow
installed.~~ Not exactly true at this point...

### Gnu Stow

This project makes use of GNU Stow which is basically a "symlink farm manager".
More info about GNU Stow and how to use it can be found [here](https://www.gnu.org/software/stow/).

## Usage

I feel the best way to explain how something works is to do it with an example.
Let's say we have done some changes to our Emacs configurations and want to
apply them to our system. All Emacs related stuff is contained in the emacs
folder in the project, let's check out how to *stow* it:

```bash
# cwd: ~/
cd dotfiles
stow emacs
```

Now everything in the emacs folder has been created in the home directory as
symlinks and is ready to go. Important note, everything has the exact same
structure as in the emacs folder. See the GNU Stow website for more information.
