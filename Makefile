GITHUB_REPOSITORY ?= $(shell git config --get remote.origin.url | sed -E 's/.*github.com[:\/](.*)\.git/\1/')
GITHUB_REPOSITORY_OWNER ?= $(shell echo $(GITHUB_REPOSITORY) | cut -d/ -f1)
GITHUB_REPOSITORY_NAME ?= $(shell echo $(GITHUB_REPOSITORY) | cut -d/ -f2)
HELM_NAMESPACE ?= $(NAMESPACE)
HELM_OPTS ?= $(OPTS)
HELM_RELEASE ?= $(RELEASE)
NAMESPACE ?= synology-csi
RELEASE ?= $(NAMESPACE)
REPO_URL ?= https://$(GITHUB_REPOSITORY_OWNER).github.io/$(GITHUB_REPOSITORY_NAME)

.DEFAULT_GOAL := upgrade

custom.yaml:
	touch $@

.PHONY: diff
diff: custom.yaml
	helm diff upgrade $(HELM_RELEASE) . \
		--context 3 \
		--namespace $(HELM_NAMESPACE) \
		--values .values.yaml \
		$(HELM_OPTS)

.PHONY: dist
dist:
	helm package . --destination dist
	curl --fail --output-dir dist --remote-name --silent $(REPO_URL)/index.yaml || true
	helm repo index dist --merge dist/index.yaml --url $(REPO_URL)
	helm push ./dist/*.tgz oci://ghcr.io/$(GITHUB_REPOSITORY)

.PHONY: template
template: custom.yaml
	helm template $(HELM_RELEASE) . \
		--namespace $(HELM_NAMESPACE) \
		--values .values.yaml \
		$(HELM_OPTS)

.PHONY: test
test: custom.yaml
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
upgrade up: custom.yaml
	helm upgrade $(HELM_RELEASE) . \
		--create-namespace \
		--install \
		--namespace $(HELM_NAMESPACE) \
		--values .values.yaml \
		$(HELM_OPTS)
