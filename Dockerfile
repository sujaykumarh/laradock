FROM php:8.3-fpm

#trigger build

########
#### Setup ENV Vars
########

ARG LARAVEL_UID="1000" \
    LARAVEL_GID="1000" \
    LARAVEL_USER="laravel" \
    LARAVEL_GROUP="laravel" \
    LARAVEL_USERHOME="/home/laravel" \
    LARAVEL_WORKDIR="/app" \
    LARAVEL_APPDIR="/app" \
    LARAVEL_DATADIR="/app/.data" \
    PHP_EXT_INSTALLER_VER="latest"

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_HOME="${LARAVEL_USERHOME}/.composer"  \
    COMPOSER_ALLOW_SUPERUSER="0"

COPY --chmod=0755 --from=composer/composer:latest-bin /composer /usr/bin/composer

# COPY --chmod=0755 --from=oven/bun:alpine /usr/local/bin/bun /usr/bin/bun

COPY --chmod=755 ./.docker/scripts/* /usr/local/sbin/

### Custom SHELL
COPY --chmod=755 ./.docker/files/bashrc.sh /bashrc.sh

### Custom EntryPoint
COPY --chmod=755 ./.docker/docker-entrypoint.sh /usr/bin/entrypoint.sh



########
#### ADD default $USER & App Dirs / Files
########

##
# username : ${LARAVEL_USER}
# group    : ${LARAVEL_GROUP}
# home dir [-h] / no password [-D] / default shell ash [-s]
##

RUN echo "Setting up user dirs.."; \
        mkdir -p ${LARAVEL_APPDIR} ${LARAVEL_DATADIR} ${LARAVEL_USERHOME}; \
    \
    echo "Setting up default '${LARAVEL_USER}' user.."; \
        groupadd -g ${LARAVEL_GID} ${LARAVEL_GROUP}; \
        useradd  -u ${LARAVEL_UID} -g ${LARAVEL_GROUP} -s /bin/bash ${LARAVEL_USER} -d ${LARAVEL_USERHOME}; \
        chmod g+wx ${LARAVEL_USERHOME}; \
        chmod g+wx ${LARAVEL_APPDIR}; \
    \
    echo "Setting up composer cache dir.."; \
        mkdir ${COMPOSER_HOME}; \
        chmod g+wx ${COMPOSER_HOME}; \
    \
    echo "Setting up general files.."; \
        mv /bashrc.sh ${LARAVEL_USERHOME}/.bashrc; \
    \
    echo "Setting up basic laravel dirs.."; \
    mkdir -p \
        ${LARAVEL_APPDIR}/.data \
        ${LARAVEL_APPDIR}/app \
        ${LARAVEL_APPDIR}/bootstrap/cache \
        ${LARAVEL_APPDIR}/config \
        ${LARAVEL_APPDIR}/database \
        ${LARAVEL_APPDIR}/lang \
        ${LARAVEL_APPDIR}/Modules \
        ${LARAVEL_APPDIR}/public \
        ${LARAVEL_APPDIR}/resources \
        ${LARAVEL_APPDIR}/routes \
        ${LARAVEL_APPDIR}/storage/framework/cache \
        ${LARAVEL_APPDIR}/storage/framework/sessions \
        ${LARAVEL_APPDIR}/storage/framework/testing \
        ${LARAVEL_APPDIR}/storage/framework/views \
        ${LARAVEL_APPDIR}/stubs \
        ${LARAVEL_APPDIR}/node_modules \
        ${LARAVEL_APPDIR}/vendor; \
    \
    echo "Making required empty files..."; \
        echo "{}" >> ${LARAVEL_APPDIR}/composer.json; \
        echo "{}" >> ${LARAVEL_APPDIR}/composer.lock; \
        echo "{}" >> ${LARAVEL_APPDIR}/package.json; \
        echo "{}" >> ${LARAVEL_APPDIR}/modules_statuses.json; \
        echo "" >> ${LARAVEL_APPDIR}/tailwind.config.js; \
        echo "" >> ${LARAVEL_APPDIR}/vite.config.js; \
        echo "" >> ${LARAVEL_APPDIR}/.data/db.sqlite; \
    \
    echo "Fixing files & dir permissions..."; \
        chmod 755 /usr/bin/entrypoint.sh; \
        chmod 755 ${LARAVEL_USERHOME}/.bashrc; \
        chown -R ${LARAVEL_UID}:${LARAVEL_GID} ${LARAVEL_APPDIR}; \
        chown -R ${LARAVEL_UID}:${LARAVEL_GID} ${LARAVEL_USERHOME};

########
#### Install Packages
########

## required packages 
RUN echo "Install required Packages..."; \
        apt update && \
        apt install -y --no-install-recommends \
            nano \
            unzip \
            zip;

# Install BUN to user
USER $LARAVEL_USER
RUN echo "Installing bun..."; \ 
        curl -fsSL https://bun.sh/install | bash;
USER root

## For LARAVEL

# Laravel Required extensions   https://laravel.com/docs/11.x/deployment#server-requirements
# ctype, curl, dom, fileinfo, filter, hash, mbstring, openssl, pcre, pdo, session, tokenizer, xml

# check available extensions    docker run --rm php:8.3-cli php -m

# installed with php    ::  curl, ctype, dom, fileinfo, filter, hash, mbstring, openssl, pcre, pdo, session, tokenizer, xml
# Extra         ::  pdo_mysql, pdo_pgsql, zip, yaml, gd, csv, mcrypt, opcache, tidy, redis

# Install & cleanup
RUN echo "Install Required php extensions..."; \
    curl -sSL https://github.com/mlocati/docker-php-extension-installer/releases/${PHP_EXT_INSTALLER_VER}/download/install-php-extensions  -o - | sh -s \
        pdo_mysql pdo_pgsql \
        exif \
        imagick \
        json \
        zip \
        yaml \
        gd \
        csv \
        intl \
        mcrypt \
        opcache \
        tidy \
        redis;\
        docker-php-ext-configure intl && \
    \
    echo "Install PHP intl..."; \
        docker-php-ext-install intl && \
        docker-php-ext-enable intl && \
        { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; }; \
    \
    echo "Remove unnecessary files..."; \
        apt clean autoclean; \
        apt autoremove --yes; \
        rm -rf /usr/local/lib/php/doc/*; \
        rm -rf /var/lib/apt/lists/*; \
        rm -rf /var/lib/{apt,dpkg,cache,log}/; \
        rm -rf /var/log/*; \
        rm -rf /tmp/*; \
    \
    echo "cleaned up after install";


## Set Default USER
USER $LARAVEL_USER

## Set Working DIR
WORKDIR $LARAVEL_APPDIR

## Expose PORTS
EXPOSE 80

## Set Entrypoint
ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]

## Default Command
CMD [ "/bin/bash" ]