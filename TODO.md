# TODO

## Makefile
I want a Makefile that makes it quick and easy to stow my packages and install dependencies as well as removing stows.
- [ ] make stow
- [ ] make install_deps
- [ ] make clean

### Notes for install_deps
`make install_deps` should call the `.scripts/install_deps.sh` script which handles the installation of all the dependencies.

### Notes for stow
I want to stow all folders on the toplevel that are "unhidden" (isn't prepended with a `.`).
