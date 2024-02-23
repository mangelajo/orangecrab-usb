USE_CONTAINERS ?= yes
CONTAINER_IMAGE ?= quay.io/mangelajo/fedora-hdl-tools:latest

ifeq (yes,$(USE_CONTAINERS))
	ifneq (, $(shell which podman 2>/dev/null))
		CONTAINER_ENGINE ?= podman
		ifneq (, $(shell which docker 2>/dev/null))
			CONTAINER_ENGINE ?= docker
		endif
	endif
endif

ifeq (,$(CONTAINER_ENGINE))
    $(warning "No podman or docker installed, consider installing them to build from containers and avoid the need to install all synthesis tools locally")
else 
    $(info Using container engine: $(CONTAINER_ENGINE))
    IN_CONTAINER ?= $(CONTAINER_ENGINE) run --rm -v $(PWD):/wrk:z -w /wrk $(CONTAINER_IMAGE)
endif
