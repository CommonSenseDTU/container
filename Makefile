PM = brew

.PHONY: all
all: schemas omh-dsu-ri researcher-ui nginx

.PHONY: schemas
schemas:
	cd schemas && ./gradlew build publishToMavenLocal

.PHONY: omh-dsu-ri
omh-dsu-ri:
	cd omh-dsu-ri && ./gradlew build -x test

.PHONY: researcher-ui
researcher-ui:
	cd researcher-ui && $(MAKE) install
	cd researcher-ui && $(MAKE) all

.PHONY: nginx
nginx: etc/nginx.conf.in
	if [[ `which nginx` == "" ]]; then $(PM) install nginx ; fi
	perl -ane "s|RESEARCHERUI|`pwd`|;print" < etc/nginx.conf.in > etc/nginx.conf

.PHONY: run-omh
run-omh:
	cd omh-dsu-ri && docker-compose -f docker-compose-build.yml up -d

.PHONY: run-ui
run-ui:
	cd researcher-ui && $(MAKE) start &
	nginx -c `pwd`/etc/nginx.conf

.PHONY: run
run: run-omh run-ui

.PHONY: update-submodules
update-submodules:
	cd schemas && git pull
	cd omh-dsu-ri && git pull
	cd researcher-ui && git pull
