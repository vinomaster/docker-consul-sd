
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

# Start Single Node Env
start-single:
	@docker run -d --restart=always -p 127.0.0.1:8400:8400 -p 127.0.0.1:8500:8500 -p 127.0.0.1:8600:53/udp -p 172.17.42.1:8400:8400 -p 172.17.42.1:8500:8500 -p 172.17.42.1:8600:53/udp --name consulserver -h consulserver trusty/consul /usr/local/sbin/consul agent -server -client=0.0.0.0 -bootstrap-expect 1 -data-dir /tmp/consul

# Start Multi Node Env
start-cluster:
	./consulcluster
