FROM lsiobase/alpine:3.10

ARG BUILD_DATE
ARG VERSION
ARG QUASSELWEB_COMMIT
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chbmb"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
    curl \
    git && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	npm && \
 echo "**** install quassel webserver ****" && \
 mkdir -p \
   /app/quassel-web && \
 if [ -z ${QUASSELWEB_COMMIT+x} ]; then \
       QUASSELWEB_COMMIT=$(curl -sX GET https://api.github.com/repos/magne4000/quassel-webserver/commits/master \
       | awk '/sha/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/quassel-web.tar.gz -L \
        "https://github.com/magne4000/quassel-webserver/archive/${QUASSELWEB_COMMIT}.tar.gz" && \
 tar xf \
 /tmp/quassel-web.tar.gz -C \
        /app/quassel-web --strip-components=1 && \
 cd /app/quassel-web && \
 npm install && \
 echo "**** cleanup ****" && \
 cp /app/quassel-web/settings.js /defaults && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root && \
 mkdir -p \
	/root
# add local files
COPY root/ /
# ports and volumes
EXPOSE 64080 64443
