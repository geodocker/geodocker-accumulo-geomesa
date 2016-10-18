BASE := $(subst -, ,$(notdir ${CURDIR}))
ORG  := $(word 1, ${BASE})
REPO := $(word 2, ${BASE})-$(word 3, ${BASE})
IMG  := quay.io/${ORG}/${REPO}
GEOMESA_VERSION := 1.2.6
DIST_TARBALL := tarballs/geomesa-dist-${GEOMESA_VERSION}-bin.tar.gz
TOOL_TARBALL := geomesa-tools-${GEOMESA_VERSION}-bin.tar.gz
RUNTIME := geomesa-accumulo-distributed-runtime-${GEOMESA_VERSION}.jar

build: ${RUNTIME} ${TOOL_TARBALL}
	docker build \
		--build-arg GEOMESA_VERSION=${GEOMESA_VERSION} \
		-t ${IMG}:latest .

${DIST_TARBALL}:
	(cd tarballs ; curl -L -C - -O "https://repo.locationtech.org/content/repositories/geomesa-releases/org/locationtech/geomesa/geomesa-dist/${GEOMESA_VERSION}/geomesa-dist-${GEOMESA_VERSION}-bin.tar.gz")

${TOOL_TARBALL}: ${DIST_TARBALL}
	tar zxvf $<
	cp geomesa-${GEOMESA_VERSION}/dist/tools/${TOOL_TARBALL} .

${RUNTIME}: ${TOOL_TARBALL}
	cp geomesa-${GEOMESA_VERSION}/dist/accumulo/${RUNTIME} .

publish: build
	docker push ${IMG}:latest
	if [ "${TAG}" != "" -a "${TAG}" != "latest" ]; then docker tag ${IMG}:latest ${IMG}:${TAG} && docker push ${IMG}:${TAG}; fi

test: build
	docker-compose up -d
	docker-compose run --rm accumulo-master bash -c "set -e \
		&& source /sbin/accumulo-lib.sh \
		&& wait_until_accumulo_is_available accumulo zookeper \
		&& accumulo shell -p GisPwd -e 'info'"
	docker-compose down

clean:
	rm -rf geomesa-${GEOMESA_VERSION}/

cleaner: clean
	rm -f ${RUNTIME} ${TOOL_TARBALL}

cleanest: cleaner
	rm -f ${DIST_TARBALL}
