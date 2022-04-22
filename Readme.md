# HOW TO:

1. add/create ./data/config/config.ini for server configuration
2. add/create ./data/mods/mod-list.json for mods
3. add/create ./data/saves/<some_name>.zip (or not to create a new map)
4. add/create ./auth.env with ACCOUNT and TOKEN for authentication (optionally RCON_PASSWORD)
5. docker-compose run factorio (or ./make_systemd_service.bash)
6. ???
7. The factory must grow!

# TODO:

* [x] factorio_updater
* [x] mod_updater.py

# Thanks:

* https://github.com/GameServers/Factorio
* https://github.com/factoriotools/factorio-docker
