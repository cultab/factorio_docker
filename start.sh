#!/bin/sh

# fact_path="/opt/factorio/bin/x64/factorio"
# mods_path="/opt/factorio/mods"
# data_path="/opt/factorio/player-data.json"
# settings_path="/opt/factorio/data/server-settings.json"

# update mods if needed
if [ "$UPDATE_GAME_ON_START" ]; then
    echo "Updating factorio.."
    python3 /opt/factorio/update_factorio.py \
            --apply-to /opt/factorio/bin/x64/factorio \
            --delete-after-applying \
            -u "${USERNAME}" -t "${TOKEN}"
            # --server-settings $settings_path \
fi

# update mods if needed
if [ "$UPDATE_MODS_ON_START" ]; then
    echo "Updating mods.."
    python3 /opt/factorio/mod_updater.py \
            --fact-path /opt/factorio/bin/x64/factorio \
            --mod-directory /opt/factorio/mods \
            -u "${USERNAME}" -t "${TOKEN}" --update
            # --server-settings $settings_path \
fi

# test if save already exists
if ! find "/factorio/saves/" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
    # if not create it
    echo "Creating new save.."
    /opt/factorio/bin/x64/factorio --create /factorio/saves/new_save.zip
    echo "Now loading newly created save.."
else
    echo "Loading lastest save.."
fi

# now start
/opt/factorio/bin/x64/factorio --start-server-load-latest
