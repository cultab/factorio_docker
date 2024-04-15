FROM debian:10

ARG USER=factorio
ARG GROUP=factorio

ENV SAVES=/factorio/saves \
    CONFIG=/factorio/config \
    MODS=/factorio/mods \
    SCENARIOS=/factorio/scenarios \
    SCRIPTOUTPUT=/factorio/script-output

# update and install required packages
RUN apt-get update &&\
    apt-get upgrade -y &&\
    apt-get install -y unzip \
                       p7zip-full \
                       curl \
                       wget \
                       lib32gcc1 \
                       iproute2  \
                       vim-tiny \
                       bzip2 \
                       jq \
                       software-properties-common \
                       apt-transport-https \
                       python3 \
                       python3-pip \
                       lib32stdc++6 &&\
    apt-get clean &&\
    python3 -m pip install requests

# version checksum of the archive to download
ARG VERSION
ARG SHA256

# install factorio
RUN if [ -z "$VERSION" ]; then \
        echo "build-arg VERSION is required" &&\
        exit 1; \
    fi &&\
    if [ -z "$SHA256" ]; then \
        echo "build-arg SHA256 is required" &&\
        exit 1; \
    fi &&\
    archive="/tmp/factorio_headless_x64_${VERSION}.tar.xz" &&\
    mkdir -p /opt /factorio &&\
    curl -sSL "https://www.factorio.com/get-download/${VERSION}/headless/linux64" -o "$archive" &&\
    if [ "$SHA256" != "SKIP" ]; then \
        echo "$SHA256  $archive" | sha256sum -c || (sha256sum "$archive" && file "$archive" && exit 1) \
    fi && \
    tar -axf "$archive" --directory /opt &&\
    rm "$archive"

ARG FACTORIO_UPDATER_COMMIT
ARG FACTORIO_UPDATER_SHA256

# install factorio-updater
RUN if [ -z "${FACTORIO_UPDATER_COMMIT}" ]; then \
        echo "build-arg FACTORIO_UPDATER_COMMIT is required" &&\
        exit 1; \
    fi &&\
    if [ -z "${FACTORIO_UPDATER_SHA256}" ]; then \
        echo "build-arg FACTORIO_UPDATER_SHA256 is required" &&\
        exit 1; \
    fi &&\
    archive="/tmp/factorio_updater.zip" &&\
    mkdir -p /opt /factorio &&\
    curl -sSL "https://github.com/narc0tiq/factorio-updater/archive/${FACTORIO_UPDATER_COMMIT}.zip" -o "$archive" &&\
    if [ "$FACTORIO_UPDATER_SHA256" != "SKIP" ]; then \
        echo "$FACTORIO_UPDATER_SHA256  $archive" | sha256sum -c || (sha256sum "$archive" && file "$archive" && exit 1) \
    fi && \
    7z e "$archive" -o"/tmp/factorio-updater-${FACTORIO_UPDATER_COMMIT}" &&\
    rm "$archive" &&\
    cp "/tmp/factorio-updater-${FACTORIO_UPDATER_COMMIT}/update_factorio.py" /opt/factorio/update_factorio.py &&\
    rm -rf "/tmp/factorio-updater-${FACTORIO_UPDATER_COMMIT}/"

ARG MOD_UPDATER_VERSION
ARG MOD_UPDATER_SHA256

# install mod_updater.py
RUN if [ -z "$MOD_UPDATER_VERSION" ]; then \
        echo "build-arg MOD_UPDATER_VERSION is required" &&\
        exit 1; \
    fi &&\
    if [ -z "$MOD_UPDATER_SHA256" ]; then \
        echo "build-arg MOD_UPDATER_SHA256 is required" &&\
        exit 1; \
    fi &&\
    archive="/tmp/${MOD_UPDATER_VERSION}.tar.gz" &&\
    mkdir -p /opt /factorio &&\
    curl -sSL "https://github.com/pdemonaco/factorio-mod-updater/archive/refs/tags/${MOD_UPDATER_VERSION}.tar.gz" -o "$archive" &&\
    if [ "$MOD_UPDATER_SHA256" != "SKIP" ]; then \
        echo "$MOD_UPDATER_SHA256  $archive" | sha256sum -c || (sha256sum "$archive" && file "$archive" && exit 1) \
    fi && \
    tar -axf "$archive" --directory /tmp/ &&\
    rm "$archive" &&\
    cp "/tmp/factorio-mod-updater-${MOD_UPDATER_VERSION}/mod_updater.py" /opt/factorio/mod_updater.py &&\
    rm -rf "/tmp/factorio-mod-updater-${MOD_UPDATER_VERSION}/"

RUN adduser --disabled-password --gecos "" "$USER"

# ownership and symlink /factorio with actual locations
RUN chmod ug=rwx /opt/factorio &&\
    mkdir -p /opt/factorio/config/ &&\
    ln -s "$SCENARIOS" /opt/factorio/scenarios &&\
    ln -s "$CONFIG" /opt/factorio/config &&\
    ln -s "$SAVES" /opt/factorio/saves &&\
    ln -s "$MODS" /opt/factorio/mods &&\
    chown -R "$USER":"$GROUP" /opt/factorio /factorio

# install start script
COPY start_factorio.sh /opt/factorio/start_factorio.sh
RUN chmod ug=rwx /opt/factorio/start_factorio.sh &&\
    chown "$USER":"$GROUP" /opt/factorio/start_factorio.sh

# start!
USER factorio
CMD ["/bin/sh", "-c", "/opt/factorio/start_factorio.sh"]
