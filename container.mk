bin/.container: container/Containerfile
	podman build -f container/Containerfile . -t quay.io/mangelajo/orangecrab-usb:latest
	touch bin/.container

container: bin/.container

PWD = $(shell pwd)

ifneq (, $(shell which podman 2>/dev/null))
 xCONTAINER_ENGINE ?= podman
 ifneq (, $(shell which docker 2>/dev/null))
   xCONTAINER_ENGINE ?= docker
 endif
endif

ifeq (,$(CONTAINER_ENGINE))
  $(warning "No podman or docker installed, consider installing them to build from containers and avoid the need to install all synthesis tools locally")
else 
  $(info Using container engine: $(CONTAINER_ENGINE))
  IN_CONTAINER ?= $(CONTAINER_ENGINE) run --rm -v $(PWD):/wrk:z -w /wrk quay.io/mangelajo/orangecrab-usb:latest
endif
