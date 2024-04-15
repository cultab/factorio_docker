#!/bin/sh

# fact_path="/opt/factorio/bin/x64/factorio"
# mods_path="/opt/factorio/mods"
# data_path="/opt/factorio/player-data.json"
# settings_path="/opt/factorio/data/server-settings.json"

factorio="/opt/factorio/bin/x64/factorio"

# configure rcon
factorio="$factorio --rcon-port 27015"

if [ -z "$RCON_PASSWORD" ]; then
    RCON_PASSWORD=$(tr -dc 'a-f0-9' < /dev/urandom | head -c16)
    echo "RCON password is: '$RCON_PASSWORD'"
fi

echo "Setting rcon password.."
factorio="$factorio --rcon-password ${RCON_PASSWORD}"

# update mods if needed
if [ "$UPDATE_GAME_ON_START" = "true" ]; then
    echo "Updating factorio.."
    python3 /opt/factorio/update_factorio.py \
            --apply-to /opt/factorio/bin/x64/factorio \
            --delete-after-applying \
            -u "${USERNAME}" -t "${TOKEN}"
fi

# update mods if needed
if [ "$UPDATE_MODS_ON_START" = "true" ]; then
    echo "Updating mods.."
    python3 /opt/factorio/mod_updater.py \
            --fact-path /opt/factorio/bin/x64/factorio \
            --mod-directory /opt/factorio/mods \
            -u "${USERNAME}" -t "${TOKEN}" --update
fi

# test if save already exists
if ! find "/factorio/saves/" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
    # if not create it
    echo "Creating new save.."
    $factorio --create /factorio/saves/new_save.zip
    echo "Now loading newly created save.."
else
    echo "Loading lastest save.."
fi

# now start
$factorio --start-server-load-latest
