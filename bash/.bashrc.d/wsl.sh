# WSL
# ---
# Exit early if not in WSL
if [ ! -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    return
fi

export BROWSER="/mnt/c/Windows/explorer.exe"

alias bat=batcat
