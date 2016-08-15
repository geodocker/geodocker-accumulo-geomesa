BASE := $(subst -, ,$(notdir ${CURDIR}))
ORG  := $(word 1, ${BASE})
REPO := $(word 2, ${BASE})-$(word 3, ${BASE})
IMG  := quay.io/${ORG}/${REPO}
GEOMESA_VERSION := 1.2.5

build: geomesa-accumulo-distributed-runtime-${GEOMESA_VERSION}.jar geomesa-tools-${GEOMESA_VERSION}-bin.tar.gz
	docker build \
		--build-arg GEOMESA_VERSION=${GEOMESA_VERSION} \
		-t ${IMG}:latest .

geomesa-dist-${GEOMESA_VERSION}-bin.tar.gz:
	curl -L -C - -O "https://repo.locationtech.org/content/repositories/geomesa-releases/org/locationtech/geomesa/geomesa-dist/${GEOMESA_VERSION}/geomesa-dist-${GEOMESA_VERSION}-bin.tar.gz"

geomesa-tools-${GEOMESA_VERSION}-bin.tar.gz: geomesa-dist-${GEOMESA_VERSION}-bin.tar.gz
	tar zxvf $<
	cp geomesa-${GEOMESA_VERSION}/dist/tools/geomesa-tools-${GEOMESA_VERSION}-bin.tar.gz .

geomesa-accumulo-distributed-runtime-${GEOMESA_VERSION}.jar: geomesa-tools-${GEOMESA_VERSION}-bin.tar.gz geomesa-dist-${GEOMESA_VERSION}-bin.tar.gz
	cp geomesa-${GEOMESA_VERSION}/dist/accumulo/geomesa-accumulo-distributed-runtime-${GEOMESA_VERSION}.jar .

publish: build
	docker push ${IMG}:latest
	if [ "${TAG}" != "" -a "${TAG}" != "latest" ]; then docker tag ${IMG}:latest ${IMG}:${TAG} && docker push ${IMG}:${TAG}; fi

test: build
	docker-compose up -d
	docker-compose run --rm accumulo-master bash -c "set -e \
		&& source /sbin/accumulo-lib.sh \
		&& wait_until_accumulo_is_available \
		&& accumulo shell -p GisPwd -e 'info'"
	docker-compose down

clean:
	rm -rf geomesa-${GEOMESA_VERSION}/

cleaner: clean
	rm -f geomesa-tools-${GEOMESA_VERSION}-bin.tar.gz
	rm -f geomesa-accumulo-distributed-runtime-${GEOMESA_VERSION}.jar

cleanest: cleaner
	rm -f geomesa-dist-${GEOMESA_VERSION}-bin.tar.gz
