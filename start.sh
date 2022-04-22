#!/bin/sh


fact_path="/opt/factorio/bin/x64/factorio"
mods_path="/opt/factorio/mods"
# data_path="/opt/factorio/player-data.json"
# settings_path="/opt/factorio/data/server-settings.json"

. /factorio/env

echo ${ACCOUNT} ${TOKEN}

python3 /factorio/mod_updater.py \
        --fact-path $fact_path \
        --mod-directory $mods_path \
        -u ${ACCOUNT} -t ${TOKEN} --update
        # --server-settings $settings_path \

if find "/factorio/saves/" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
    echo "loading lastest.."
    /opt/factorio/bin/x64/factorio --start-server-load-latest
else
    echo "creating new.."
    /opt/factorio/bin/x64/factorio --create /factorio/saves/new_save.zip
    echo "now loading new.."
    /opt/factorio/bin/x64/factorio --start-server-load-latest
fi
