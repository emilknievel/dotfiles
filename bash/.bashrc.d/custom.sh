copy() {
  if hash pbcopy 2>/dev/null; then
    exec pbcopy
  elif hash xclip 2>/dev/null; then
    exec xclip -selection clipboard
  elif hash putclip 2>/dev/null; then
    exec putclip
  else
    rm -f /tmp/clipboard 2> /dev/null
    if [ $# -eq 0 ]; then
      cat > /tmp/clipboard
    else
      cat "$1" > /tmp/clipboard
    fi
  fi
}

pasta() {
  if hash pbpaste 2>/dev/null; then
    exec pbpaste
  elif hash xclip 2>/dev/null; then
    exec xclip -selection clipboard -o
  elif [[ -e /tmp/clipboard ]]; then
    exec cat /tmp/clipboard
  else
    echo ''
  fi
}

cdls() {
  if [ $# -eq 0 ]; then
    cd && ls --color=auto
  else
    local dir="${1}"
    shift
    cd "${dir}" && ls --color=auto "$@"
  fi
}
