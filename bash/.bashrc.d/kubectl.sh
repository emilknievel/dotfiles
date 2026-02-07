# =====================
# Kubectl configuration
# =====================
#
# Provides aliases and functions for kubectl if the command is available.
# Skipped if kubectl is not installed.

command -v kubectl >/dev/null 2>&1 || return 0

## Aliases

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

alias kport='kubectl port-forward'

## Functions

kroll() {
	if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "Usage: kroll <resource_type/name> [namespace]"
		echo "Example: kroll deployment/myapp"
		echo "Example: kroll deployment/myapp mynamespace"
		return 1
	fi

	resource=$1
	namespace=${2:-}
	ns_flag=""

	if [ -n "$namespace" ]; then
		ns_flag="-n $namespace"
	fi

	echo "Restarting $resource..."
	kubectl rollout restart "$resource" "$ns_flag" || return 1

	echo "Watching rollout status..."
	kubectl rollout status "$resource" "$ns_flag" -w
}
