# Docker Privoxy HTTPS

## :page_with_curl: About

Alpine docker with [privoxy](https://www.privoxy.org) with SSL support and encrypted traffic inspection capabilities enabled.

This project is based on '[Alexandre Díaz's work](https://github.com/Tardo/docker-privoxy-https)', which includes the script made by '[Andrwe Lord Weber](https://github.com/Andrwe/privoxy-blocklist)' to translate adblock rules to privoxy.

This is a simplified docker container without Alexandre's privman tool (Privoxy manager) and other Python dependencies. Supervisord has also been removed.

The entrypoint includes a function to automatically generate a self-signed CA certificate, so you don't need to issue and sign your own. If you define a volume, privoxy's CA directory can be made persistent across container restarts. The entrypoint script won't issue new certificates if it finds that a CA has already been created.

**:construction_worker: Work in progress. The default configuration is intended for personal use only.**
