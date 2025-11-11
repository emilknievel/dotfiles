# List number of session jobs in prompt
jobs_count() {
    local job_count
    job_count=$(jobs | grep -cv "Done")
    if [ "$job_count" -gt 0 ]; then
        echo "[$job_count]"
    else
        echo ""
    fi
}

if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
else
    export PROMPT_DIRTRIM=1
    export PROMPT_COMMAND='history -a; JOB_COUNT=$(jobs_count)'
    # shellcheck disable=SC2153
    export PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]${JOB_COUNT}\$ '
fi
