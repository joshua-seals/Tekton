## This makefile assumes zsh shell 
## 🐳 FIRST -- Ensure docker desktop is running. 

# SECOND (RUN ONLY ONCE) 
# 🐚 SETUP KUBECONFIG ENV IN SHELL
# If using multiple clusters, the existing cluster will be moved to file called config_old
# Kind creates and destroys /.kube/config with each kind-up and kind-down command
# Once the KUBECONFIG env is added to shell, navigate contexts with:
#			kubectl config use-context [tab|tab]  -- this will show both tekton and older cluster to select from.
check-kubeconfig:
	mv $$HOME/.kube/config $$HOME/.kube/config_old
	echo "export KUBECONFIG=$$HOME/.kube/config:$$HOME/.kube/config_old" >> $$HOME/.zshrc 
	source $$HOME/.zshrc


#================================= BELOW SETUP CAN BE RUN VIA "MAKE all" ===================================

SHELL := /bin/zsh

#Enter Cluster preference here. minkube or kind
CLUSTER := minikube
CLUSTER_NAME := tekton

minikube-up:
	minikube start --kubernetes-version v1.24.4 --name $(CLUSTER_NAME)

minikube-down:
	minkube delete 


kind-up:
	kind create cluster --name $(CLUSTER_NAME) \
		--image=kindest/node:v1.24.7@sha256:577c630ce8e509131eab1aea12c022190978dd2f745aac5eb1fe65c0807eb315

kind-down:
	kind delete cluster --name $(CLUSTER_NAME)

###### SETUP THE MAC LOCAL ENV 
# Install cli tools needed.
 
cli.setup.mac:
	brew update
	brew list kubectl || brew install kubectl
	brew list $(CLUSTER) || brew install $(CLUSTER)
	brew list tektoncd-cli || brew install tektoncd-cli
	echo "autoload -U compinit; compinit" >> ~/.zshrc
	echo "source <(tkn completion zsh)" >> ~/.zshrc 

 
##### 😺 😺 SETUP TEKTON 😺 😺
# Install Tekton Pipelines 👉 ref: https://tekton.dev/docs/installation/pipelines/
# Add tkn auto-completion 
# Ensure persistance for autocompletion
# Install Tekton-Dashboard, once installed you will need to run 'kubectl --namespace tekton-pipelines port-forward svc/tekton-dashboard 9097:9097' to access.

tekton.pipeline.setup.mac:
	kubectl apply --filename \
		https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
	kubectl apply --filename \
		https://github.com/tektoncd/dashboard/releases/latest/download/tekton-dashboard-release.yaml
	
	
# Install Tekton-Triggers and Interceptors. 👉 ref: https://tekton.dev/docs/triggers/install/
# Install Trigger perms file 👻 **This will need to be looked at particularly for (non-local) tekton implementation, as it does grant cluster-admin priv.
tekton.trigger.setup.mac:
	kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
	kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
	kubectl apply --filename https://raw.githubusercontent.com/tektoncd/triggers/main/examples/rbac.yaml 
	


# 🤖 Install all the above with exception to "check-kubeconfig"
all: cli.setup.mac $(CLUSTER)-up tekton.pipeline.setup.mac 