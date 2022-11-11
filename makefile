SHELL := /bin/zsh

KIND_CLUSTER := tekton-testing

kind-up:
	kind create cluster --name $(KIND_CLUSTER)

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)

###### SETUP THE MAC LOCAL ENV 
# Install cli tools needed.
cli.setup.mac:
	brew update
	brew list kubectl || brew install kubectl
	brew list kind || brew install kind
	brew list tektoncd-cli || brew install tektoncd-cli


 
##### 😺 😺 SETUP TEKTON 😺 😺
# Install Tekton Pipelines 👉 ref: https://tekton.dev/docs/installation/pipelines/
# Add tkn auto-completion 
# Ensure persistance for autocompletion
# Install Tekton-Dashboard, once installed you will need to run 'kubectl --namespace tekton-pipelines port-forward svc/tekton-dashboard 9097:9097' to access.
# Install Tekton-Triggers and Interceptors. 👉 ref: https://tekton.dev/docs/triggers/install/
# Install Trigger perms file 👻 **This will need to be looked at particularly for (non-local) tekton implementation, as it does grant cluster-admin priv.
tekton.setup.mac:
	kubectl apply --filename \
		https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
	echo "autoload -U compinit; compinit" >> ~/.zshrc
	echo "source <(tkn completion zsh)" >> ~/.zshrc 
	kubectl apply --filename \
		https://github.com/tektoncd/dashboard/releases/latest/download/tekton-dashboard-release.yaml
	kubectl apply --filename \
		https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
	kubectl apply --filename \
		https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml 
	kubectl apply --filename \
		https://raw.githubusercontent.com/tektoncd/triggers/main/examples/rbac.yaml 
	

## After building the above I became privy to 👉 https://github.com/tektoncd/plumbing/tree/main/hack (tekton_in_kind.sh) can do all of this.

# 🤖 🤖 🤖 🤖 🤖 Install all the above for clean start. 
all: cli.setup.mac  kind-up tekton.setup.mac