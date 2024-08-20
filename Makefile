HOMEPAGE_CONTAINER ?= quay.io/hybridcloudpatterns/homepage-container:latest

# Do not use selinux labeling when we are using nfs
FSTYPE=$(shell df -Th . | grep -v Type | awk '{ print $$2 }')
ifeq ($(FSTYPE), nfs)
	ATTRS = "rw"
else ifeq ($(FSTYPE), nfs4)
	ATTRS = "rw"
else
	ATTRS = "rw,z"
endif

##@ Docs tasks

.PHONY: help
# No need to add a comment here as help is described in common/
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^(\s|[a-zA-Z_0-9-])+:.*?##/ { printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: spellcheck
spellcheck: ## Runs a spellchecker on the content/ folder
	@echo "Running spellchecking on the tree"
	podman run -it -v $(PWD):/tmp:$(ATTRS) docker.io/jonasbn/github-action-spellcheck:latest

.PHONY: lintwordlist
lintwordlist: ## Sorts and removes duplicates from spellcheck exception file .wordlist.txt
	@cp --preserve=all .wordlist.txt /tmp/.wordlist.txt
	@sort .wordlist.txt | tr '[:upper:]' '[:lower:]' | uniq > /tmp/.wordlist.txt
	@mv -v /tmp/.wordlist.txt .wordlist.txt