
.PHONY: help kill clean-containers clean-images build test

help:
	@echo 'Help:'
	@echo ' ToDo'

# Purge All Containers
kill:
	@docker kill $(shell docker ps -a | awk '{print $$1}')
	@docker ps -a

# Purge All Containers
clean-containers:
	@docker rm $(shell docker ps -a | awk '{print $$1}')
	@docker ps -a

# Purge All Images
clean-images:
	@docker rmi $(shell docker images | awk '{print $$3}')
	@docker images

# Setup Test Env
build:
	@docker build -t trusty/consul .
	@docker images

# Setup Test Env
test:
	chmod +x consulcluster
	./consulcluster
	@docker ps -a
