#!/bin/bash
# Create a systemd service that autostarts & manages a docker-compose instance in the current directory
# by Uli Köhler - https://techoverflow.net
# Licensed as CC0 1.0 Universal
#
# Modified for use in this project.
SERVICENAME=factorio

# Create systemd service file
tee > $SERVICENAME.service << FOE
[Unit]
Description=$SERVICENAME
Requires=docker.service
After=docker.service

[Service]
Restart=always
User=root
Group=docker
WorkingDirectory=$(pwd)
# Shutdown container (if running) when unit is started
ExecStartPre=$(which docker-compose) -f docker-compose.yml down
# Start container when unit is started
ExecStart=$(which docker-compose) -f docker-compose.yml up
# Stop container when unit is stopped
ExecStop=$(which docker-compose) -f docker-compose.yml down


[Install]
WantedBy=multi-user.target
FOE

read -r -p "Install service? [Y/n] " ans
case "$ans" in
    [Yy]*)
        sudo cp "${SERVICENAME}.service" "/etc/systemd/system/${SERVICENAME}.service" ||\
            (echo "Failed installing service!" && exit 1)
        echo "Installed service into /etc/systemd/system/${SERVICENAME}.service";;
    * ) ;;
esac

read -r -p "Start enable and start service? [Y/n] " ans
case "$ans" in
    [Yy]*)
        sudo systemctl enable "${SERVICENAME}.service" ||\
            (echo "Failed enabling service!" && exit 1)
        sudo systemctl start "${SERVICENAME}.service" ||\
            (echo "Failed starting service!" && exit 1)
        echo "Started service!";;
    * ) ;;
esac

read -r -p "Create start, stop and logtail shortcuts? [Y/n] " ans
case "$ans" in
    [Yy]*)
        echo "sudo systemctl start $SERVICENAME" > ./start
        echo "sudo systemctl stop  $SERVICENAME" > ./stop
        echo "sudo journalctl -f -u $SERVICENAME" > ./logtail
        chmod +x ./start
        chmod +x ./stop
        chmod +x ./logtail
        echo "Done!"
        ;;
    * ) ;;
esac

sudo systemctl daemon-reload
