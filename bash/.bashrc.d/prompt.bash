PROMPT_COMMAND='e=$?; errs=; [ $e -ne 0 ] && errs="($e) "; history -a'
PS1='\[\e[31m\]$errs\[\e[32m\]\u\[\e[0m\]@\[\e[34m\]\h\[\e[0m\] \$ '
