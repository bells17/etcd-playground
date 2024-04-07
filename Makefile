IMAGE ?= gcr.io/etcd-development/etcd:v3.5.12
ETCD_ENDPOINTS ?= "http://172.16.0.4:12380,http://172.16.0.5:12382,http://172.16.0.6:12384,http://172.16.0.7:12386,http://172.16.0.8:12388"

.PHONY: all
all: setup

##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

setup: ## Setup build environment.

##@ etcd cluster

.PHONY: up
up: ## Start etcd cluster.
	docker compose up -d

.PHONY: down
down: ## Shutdown etcd cluster.
	docker compose down

.PHONY: logs
logs: ## Show etcd cluster logs.
	docker compose logs -f

.PHONY: pull-image
pull-image: ## Pull etcd image.
	docker pull $(IMAGE)

##@ etcd commands

.PHONY: etcd-endpoint-status
etcd-endpoint-status: ## Run `etcdctl endpoint status` command.
	etcdctl --write-out=table --endpoints=$(ETCD_ENDPOINTS) endpoint status

.PHONY: etcd-endpoint-health
etcd-endpoint-health: ## Run `etcdctl endpoint health` command.
	etcdctl --write-out=table --endpoints=$(ETCD_ENDPOINTS) endpoint health

.PHONY: etcd-put-test
etcd-put-test:
	etcdctl --endpoints=$(ETCD_ENDPOINTS) put foo "Hello World!"
	etcdctl --endpoints=$(ETCD_ENDPOINTS) get foo
	etcdctl --endpoints=$(ETCD_ENDPOINTS) --write-out="json" get foo

.PHONY: etcd-get-key-test
etcd-get-key-test:
	etcdctl --endpoints=$(ETCD_ENDPOINTS) put web1 value1
	etcdctl --endpoints=$(ETCD_ENDPOINTS) put web2 value2
	etcdctl --endpoints=$(ETCD_ENDPOINTS) put web3 value3
	etcdctl --endpoints=$(ETCD_ENDPOINTS) get web --prefix

.PHONY: etcd-delete-keys-test
etcd-delete-keys-test:
	etcdctl --endpoints=$(ETCD_ENDPOINTS) put key myvalue
	etcdctl --endpoints=$(ETCD_ENDPOINTS) del key
	etcdctl --endpoints=$(ETCD_ENDPOINTS) put k1 value1
	etcdctl --endpoints=$(ETCD_ENDPOINTS) put k2 value2
	etcdctl --endpoints=$(ETCD_ENDPOINTS) del k --prefix

.PHONY: etcd-txn-test
etcd-txn-test:
	@export ETCD_ENDPOINTS=$(ETCD_ENDPOINTS) && cat etcd-txn-test.bash
	@export ETCD_ENDPOINTS=$(ETCD_ENDPOINTS) && bash etcd-txn-test.bash

.PHONY: etcd-watch-test
etcd-watch-test:
	etcdctl --endpoints=$(ETCD_ENDPOINTS) watch stock1

.PHONY: etcd-watch-put-test
etcd-watch-put-test:
	etcdctl --endpoints=$(ETCD_ENDPOINTS) put stock1 1000
