REPO_NAME := $(shell basename `git rev-parse --show-toplevel` | tr '[:upper:]' '[:lower:]')
GIT_TAG ?= $(shell git log --oneline | head -n1 | awk '{print $$1}')
DOCKER_REGISTRY := mathematiguy
COMPUTE ?=gpu
IMAGE := $(DOCKER_REGISTRY)/$(REPO_NAME):$(COMPUTE)
HAS_DOCKER ?= $(shell which docker)
RUN ?= $(if $(HAS_DOCKER), docker run $(DOCKER_ARGS) --rm -v $$(pwd):/$(REPO_NAME) -w /$(REPO_NAME) -u $(UID):$(GID) $(IMAGE))
UID ?= $$(id -u)
GID ?= $$(id -g)
DOCKER_ARGS ?=
mgs
.PHONY: build docker docker-push docker-pull enter enter-root

docker: Dockerfiles/.gpu.done

build: IMAGE=mathematiguy/leela-zero:gpu
build:
	mkdir -p build
	$(RUN) bash -c "cd build && cmake -j 15 .."
	$(RUN) bash -c "cd build && cmake -j 15 --build ."

Dockerfiles/.%.done: Dockerfiles/Dockerfile.%
	docker build $(DOCKER_ARGS) -t $(IMAGE) -f $< .
	touch $@

clean:
	rm -rf Dockerfiles/.*.done

enter: DOCKER_ARGS=-it
enter:
	$(RUN) bash

enter-root: DOCKER_ARGS=-it
enter-root: UID=root
enter-root: GID=root
enter-root:
	$(RUN) bash
