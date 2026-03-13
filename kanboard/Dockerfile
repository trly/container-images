FROM docker.io/kanboard/kanboard:v1.2.51

RUN apk update --no-cache && apk upgrade --no-cache

RUN PLUGIN_INSTALLER=true /var/www/app/cli plugin:install https://github.com/kanboard/plugin-oauth2/releases/download/v1.0.2/OAuth2-1.0.2.zip
RUN PLUGIN_INSTALLER=true /var/www/app/cli plugin:install https://github.com/ChristianJStarr/kanboard-mcp/releases/download/v1.0.0/ModelContextProtocol-1.0.0.zip

LABEL org.opencontainers.image.source=https://github.com/trly/container-images

