error_display() {
	local exit_status=$1
	if [ $exit_status -eq 0 ]; then
		echo ""
	else
		echo "[$exit_status]"
	fi
}

export PROMPT_DIRTRIM=1
export PROMPT_COMMAND='ERROR_DISPLAY=$(error_display $?); history -a'
# shellcheck disable=SC2153
export PS1='\[\e[32;1m\]\u@\h\[\e[0m\]:\[\e[34;1m\]\w\[\e[0m\]\$\[\e[31m\]$ERROR_DISPLAY\[\e[0m\] '
