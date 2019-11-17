CONTAINER_NAME=icecavern/awstats

all: build

.PHONY: build
build:
	docker build -t $(CONTAINER_NAME):latest .

.PHONY: run
run: stop
	docker run --name awstats --detach \
		--publish 127.0.0.1:8080:80/tcp \
		--mount "type=volume,source=awstats-config,target=/etc/awstats" \
		--mount "type=volume,source=awstats-data,target=/var/lib/awstats" \
		--mount "type=volume,source=awstats-logs,target=/var/log/awstats" \
		$(CONTAINER_NAME)

.PHONY: stop
stop:
	docker stop awstats || true
	docker rm   awstats || true

.PHONY: web
web:
	firefox http://127.0.0.1:8080/cgi-bin/awstats.pl

.PHONY: shell
shell:
	docker exec -it --user 0 $(CONTAINER_NAME) /bin/sh

DOCKER_ALPINE=docker run --rm \
	--volumes-from $(CONTAINER_NAME) \
	--mount "type=bind,source=$(PWD)/backup,target=/backup" \
	alpine

.PHONY: backup
backup:
	mkdir -p backup
	$(DOCKER_ALPINE) sh -c " \
		tar -C /etc/awstats     -czf /backup/awstats-config.tar.gz .; \
		tar -C /var/lib/awstats -czf /backup/awstats-data.tar.gz .; \
	"

.PHONY: restore
restore:
	test -f backup/awstats-config.tar.gz
	test -f backup/awstats-data.tar.gz
	$(DOCKER_ALPINE) sh -c " \
		find /etc/awstats/     -mindepth 1 -delete; \
		find /var/lib/awstats/ -mindepth 1 -delete; \
		tar -C /etc/awstats     -xzf /backup/awstats-config.tar.gz; \
		tar -C /var/lib/awstats -xzf /backup/awstats-data.tar.gz; \
	"
