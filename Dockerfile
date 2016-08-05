FROM quay.io/geodocker/accumulo:latest

MAINTAINER Pomadchin Grigory, daunnc@gmail.com

ENV GEOMESA_VERSION 1.2.4
ENV GEOMESA_DIST /opt/geomesa
ENV GEOMESA_HOME ${GEOMESA_DIST}/tools

# GeoMesa Iterators
RUN set -x \
  && mkdir -p ${GEOMESA_DIST} \
  && curl -sS -L http://repo.locationtech.org/content/repositories/geomesa-releases/org/locationtech/geomesa/geomesa-dist/${GEOMESA_VERSION}/geomesa-dist-${GEOMESA_VERSION}-bin.tar.gz \
  | tar -zx -C ${GEOMESA_DIST} --strip-components=2  geomesa-${GEOMESA_VERSION}/dist \
  && tar -xzf ${GEOMESA_DIST}/tools/geomesa-tools-${GEOMESA_VERSION}-bin.tar.gz --strip-components=1 -C ${GEOMESA_DIST}/tools \
  && ${GEOMESA_DIST}/tools/bin/install-jai.sh \
  && ${GEOMESA_DIST}/tools/bin/install-jline.sh \
  && rm -f ${GEOMESA_DIST}/tools/geomesa-tools-${GEOMESA_VERSION}-bin.tar.gz \
  && rm -rf ${GEOMESA_DIST}/gs-plugins \
  && rm -rf ${GEOMESA_DIST}/hadoop \
  && rm -rf ${GEOMESA_DIST}/web-services \
  && rm -rf ${GEOMESA_DIST}/spark

COPY ./fs /

ENTRYPOINT [ "/sbin/geomesa-entrypoint.sh" ]

