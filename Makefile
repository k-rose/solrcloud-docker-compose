IP := $(shell hostname -I | cut -d ' ' -f 1)

.PHONY: up
up:
	export WSL2_IP=$(IP) && docker compose up -d

.PHONY: start
start:
	export WSL2_IP=$(IP) && docker compose start

.PHONY: stop
stop:
	export WSL2_IP=$(IP) && docker compose stop

.PHONY: down
down:
	export WSL2_IP=$(IP) && docker compose down --volumes

.PHONY: check
check: up
	curl http://127.0.0.1:8981/solr/admin/configs?action=LIST&omitHeader=true | cat

.PHONY: upload
upload: 
	(cd ./configset/vector-search && zip -r - *) \
	| curl -X POST --header "Content-Type:application/octet-stream" --data-binary @- "http://localhost:8981/solr/admin/configs?action=UPLOAD&name=test&overwrite=true&cleanup=true"

.PHONY: create
create: upload
	curl -s "http://localhost:8981/solr/admin/collections?action=CREATE&name=test&maxShardsPerNode=1&numShards=2&replicationFactor=1&collection.configName=test"

