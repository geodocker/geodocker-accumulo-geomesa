FROM quay.io/geodocker/accumulo:0.2

MAINTAINER Pomadchin Grigory <daunnc@gmail.com>

ARG GEOMESA_VERSION
ENV GEOMESA_VERSION ${GEOMESA_VERSION}
ENV GEOMESA_DIST /opt/geomesa
ENV GEOMESA_RUNTIME ${GEOMESA_DIST}/accumulo
ENV GEOMESA_HOME ${GEOMESA_DIST}/tools
ENV PATH="${GEOMESA_HOME}/bin:${PATH}"

ADD geomesa-tools-${GEOMESA_VERSION}-bin.tar.gz /
ADD geomesa-accumulo-distributed-runtime-${GEOMESA_VERSION}.jar ${GEOMESA_RUNTIME}/

# GeoMesa Iterators
RUN set -x \
  && mv /geomesa-tools-${GEOMESA_VERSION} ${GEOMESA_HOME} \
  && (echo yes | ${GEOMESA_DIST}/tools/bin/install-jai.sh) \
  && (echo yes | ${GEOMESA_DIST}/tools/bin/install-jline.sh)

COPY ./fs /
ENTRYPOINT [ "/sbin/geomesa-entrypoint.sh" ]
