copy() {
	if hash pbcopy 2>/dev/null; then
		exec pbcopy
	elif hash xclip 2>/dev/null; then
		exec xclip -selection clipboard
	elif hash putclip 2>/dev/null; then
		exec putclip
	else
		local clip="${XDG_RUNTIME_DIR:-/tmp}/clipboard"
		mkdir -p "${clip%/*}"
		rm -f "$clip" 2> /dev/null
		if (( $# == 0 )); then
			cat > "$clip"
		else
			cat "$1" > "$clip"
		fi
	fi
}

pasta() {
	local clip="${XDG_RUNTIME_DIR:-/tmp}/clipboard"
	if hash pbpaste 2>/dev/null; then
		exec pbpaste
	elif hash xclip 2>/dev/null; then
		exec xclip -selection clipboard -o
	elif [[ -e "$clip" ]]; then
		exec cat "$clip"
	else
		echo ''
	fi
}

cdls() {
	if (( $# == 0 )); then
		cd && ls --color=auto
	else
		local dir="${1}"
		shift
		cd "${dir}" && ls --color=auto "$@"
	fi
}
