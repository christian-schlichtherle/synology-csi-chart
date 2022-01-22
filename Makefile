HELM_OPTS ?= $(OPTS)
NAMESPACE ?= synology-csi
RELEASE ?= $(NAMESPACE)
HELM_NAMESPACE ?= $(NAMESPACE)
HELM_RELEASE ?= $(RELEASE)

.PHONY: up
up:
	helm upgrade $(HELM_RELEASE) . \
		--create-namespace \
		--install \
		--namespace $(HELM_NAMESPACE) \
		$(HELM_OPTS)

.PHONY: down
down:
	helm uninstall $(HELM_RELEASE) \
		--namespace $(HELM_NAMESPACE) \
		$(HELM_OPTS)
