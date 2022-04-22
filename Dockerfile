FROM debian:10

ARG USER=factorio
ARG GROUP=factorio

# version checksum of the archive to download
ARG VERSION
ARG SHA256

ENV PORT=34197 \
    RCON_PORT=27015 \
    VERSION=${VERSION} \
    SHA256=${SHA256} \
    SAVES=/factorio/saves \
    CONFIG=/factorio/config \
    MODS=/factorio/mods \
    SCENARIOS=/factorio/scenarios \
    SCRIPTOUTPUT=/factorio/script-output \
    ACCOUNT=${ACCOUNT} \
    TOKEN=${TOKEN}

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

# install factorio
RUN if [ "${VERSION}" = "" ]; then \
        echo "build-arg VERSION is required" &&\
        exit 1; \
    fi &&\
    if [ "${SHA256}" = "" ]; then \
        echo "build-arg SHA256 is required" &&\
        exit 1; \
    fi &&\
    archive="/tmp/factorio_headless_x64_$VERSION.tar.xz" &&\
    mkdir -p /opt /factorio &&\
    curl -sSL "https://www.factorio.com/get-download/$VERSION/headless/linux64" -o "$archive" &&\
    if [ "$SHA256" != "YOLO" ]; then \
        echo "$SHA256  $archive" | sha256sum -c \
            || (sha256sum "$archive" && file "$archive" && exit 1) \
    fi && \
    tar -axf "$archive" --directory /opt &&\
    rm "$archive"

COPY files/config.ini /opt/factorio/config/config.ini
COPY start.sh /opt/factorio/start.sh
COPY files/env /opt/factorio/env

# user/ownership
RUN chmod ugo=rwx /opt/factorio &&\
    ln -s "$SCENARIOS" /opt/factorio/scenarios &&\
    ln -s "$SAVES" /opt/factorio/saves &&\
    ln -s "$MODS" /opt/factorio/mods &&\
    mkdir -p /opt/factorio/config/ &&\
    adduser --disabled-password --gecos "" "$USER" &&\
    chown -R "$USER":"$GROUP" /opt/factorio /factorio &&\
    chmod +x /opt/factorio/start.sh

# install mod_updater
RUN mod_updater_version="0.2.4" &&\
    wget https://github.com/pdemonaco/factorio-mod-updater/archive/refs/tags/${mod_updater_version}.tar.gz -O /tmp/mod_updater.tar.gz &&\
    tar -axf /tmp/mod_updater.tar.gz --directory /tmp &&\
    cp /tmp/factorio-mod-updater-${mod_updater_version}/mod_updater.py /opt/factorio/mod_updater.py

USER factorio

# start!
CMD ["/opt/factorio/start.sh"]
