.PHONY: help
.DEFAULT_GOAL := help

help: ## Display this message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

mirror: ## Mirror reposirory to dev.whatwedo.ch
	 rm -rf .mirror
	 git clone --mirror git@github.com:whatwedo/docker-base-images.git .mirror
	 cd .mirror && git push --mirror git@dev.whatwedo.ch:whatwedo/docker-base-images.git
	 rm -rf .mirror

