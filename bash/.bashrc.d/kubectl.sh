# =====================
# Kubectl configuration
# =====================
#
# Provides aliases and functions for kubectl.

command -v kubectl >/dev/null 2>&1 || return 0

alias k=kubectl
alias kls-ns='kubectl get ns'
alias kls-deploy='kubectl get deploy'
alias kls-ctx='kubectl config get-contexts'
alias kls-hpa='kubectl get hpa'
alias kls-pod='kubectl get pod'
alias kls-svc='kubectl get svc'

alias kdesc-ns='kubectl describe ns'
alias kdesc-deploy='kubectl describe deploy'
alias kdesc-hpa='kubectl describe hpa'
alias kdesc-pod='kubectl describe pod'
alias kdesc-svc='kubectl describe svc'

alias kpf='kubectl port-forward'

kroll() {
	local namespace=""
	local ns_flag=""

	while getopts ":n:h" opt; do
		case $opt in
			n) namespace="$OPTARG" ;;
			h) opt="h" ; break ;;
			\?) echo "Unknown option: -$OPTARG" ; return 1 ;;
			:) echo "Option -$OPTARG requires an argument" ; return 1 ;;
		esac
	done
	shift $((OPTIND - 1))
	OPTIND=1

	if [ $# -eq 0 ] || [ "$opt" = "h" ]; then
		echo "Usage: kroll [-n namespace] <resource_type/name>"
		echo "Example: kroll deployment/myapp"
		echo "Example: kroll -n mynamespace deployment/myapp"
		return 1
	fi

	local resource=$1

	if [ -n "$namespace" ]; then
		ns_flag="-n $namespace"
	fi

	echo "Restarting $resource..."
	kubectl rollout restart "$resource" $ns_flag || return 1

	echo "Watching rollout status..."
	kubectl rollout status "$resource" $ns_flag -w
}
