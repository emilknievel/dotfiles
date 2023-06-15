all: clean install_deps stow

install_deps: .bin/install_deps.sh
	# do some stuff

stow:
	# stow everything

clean:
	# remove stows
