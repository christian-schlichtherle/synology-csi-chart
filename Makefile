HELM_OPTS ?= $(OPTS)
NAMESPACE ?= synology-csi
RELEASE ?= $(NAMESPACE)
HELM_NAMESPACE ?= $(NAMESPACE)
HELM_RELEASE ?= $(RELEASE)

.DEFAULT_GOAL := upgrade

.PHONY: diff
diff:
	helm diff upgrade $(HELM_RELEASE) . \
		--namespace $(HELM_NAMESPACE) \
		--values local.yaml \
		$(HELM_OPTS)

.PHONY: fio
fio:
	docker buildx build --platform linux/amd64,linux/arm64 -t christianschlichtherle/fio fio --push

.PHONY: template
template:
	helm template $(HELM_RELEASE) . \
		--namespace $(HELM_NAMESPACE) \
		--values local.yaml \
		$(HELM_OPTS)

.PHONY: test
test:
	helm test $(HELM_RELEASE) \
		--namespace $(HELM_NAMESPACE) \
		--timeout 10m \
		$(HELM_OPTS)

.PHONY: uninstall down
uninstall down:
	helm uninstall $(HELM_RELEASE) \
		--namespace $(HELM_NAMESPACE) \
		$(HELM_OPTS)

.PHONY: upgrade up
upgrade up:
	helm upgrade $(HELM_RELEASE) . \
		--create-namespace \
		--install \
		--namespace $(HELM_NAMESPACE) \
		--values local.yaml \
		$(HELM_OPTS)
