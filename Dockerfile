FROM php:8.4-fpm

#trigger build

########
#### Setup ENV Vars
########

ARG LARADOCK_VER="latest" \
    LARADOCK_PLAT="amd64" \
    LARAVEL_VER="v12" \
    PHP_EXT_INSTALLER_VER="latest" \
    \
    LARAVEL_UID="1000" \
    LARAVEL_GID="1000" \
    LARAVEL_USER="laravel" \
    LARAVEL_GROUP="laravel" \
    LARAVEL_USERHOME="/home/laravel" \
    LARAVEL_WORKDIR="/app" \
    LARAVEL_APPDIR="/app" \
    LARAVEL_DATADIR="/app/.data"

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_HOME="${LARAVEL_USERHOME}/.composer"  \
    COMPOSER_ALLOW_SUPERUSER="0" \
    LARADOCK_VER="${LARADOCK_VER}" \
    LARADOCK_PLAT="${LARADOCK_PLAT}" \
    LARAVEL_VER="${LARAVEL_VER}"

### Custom Scripts
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
        ${LARAVEL_APPDIR}/.turbo \
        ${LARAVEL_APPDIR}/app \
        ${LARAVEL_APPDIR}/bootstrap/cache \
        ${LARAVEL_APPDIR}/config \
        ${LARAVEL_APPDIR}/database \
        ${LARAVEL_APPDIR}/lang \
        ${LARAVEL_APPDIR}/Modules \
        ${LARAVEL_APPDIR}/public/media \
        ${LARAVEL_APPDIR}/resources \
        ${LARAVEL_APPDIR}/routes \
        ${LARAVEL_APPDIR}/storage/app/public \
        ${LARAVEL_APPDIR}/storage/framework/cache \
        ${LARAVEL_APPDIR}/storage/framework/sessions \
        ${LARAVEL_APPDIR}/storage/framework/testing \
        ${LARAVEL_APPDIR}/storage/framework/views \
        ${LARAVEL_APPDIR}/storage/logs \
        ${LARAVEL_APPDIR}/stubs \
        ${LARAVEL_APPDIR}/tests \
        ${LARAVEL_APPDIR}/node_modules \
        ${LARAVEL_APPDIR}/vendor; \
    \
    echo "Making required empty files..."; \
        echo "{}" >> ${LARAVEL_APPDIR}/composer.json; \
        echo "{}" >> ${LARAVEL_APPDIR}/composer.lock; \
        echo "{}" >> ${LARAVEL_APPDIR}/bun.lock; \
        echo "{}" >> ${LARAVEL_APPDIR}/turbo.json; \
        echo "{}" >> ${LARAVEL_APPDIR}/tsconfig.json; \
        echo "{}" >> ${LARAVEL_APPDIR}/package.json; \
        echo "{}" >> ${LARAVEL_APPDIR}/package-lock.json; \
        echo "{}" >> ${LARAVEL_APPDIR}/pnpm-lock.json; \
        echo "{}" >> ${LARAVEL_APPDIR}/modules_statuses.json; \
        echo "" >> ${LARAVEL_APPDIR}/.gitignore; \
        echo "" >> ${LARAVEL_APPDIR}/.npmrc; \
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
#### Install Packages & CleanUp
########

RUN echo "Installing composer..."; \
        cd $HOME; php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
        php composer-setup.php --quiet; rm composer-setup.php; \
        mv composer.phar composer; \
        mv composer /usr/bin/; \
    echo "Installing packages..."; \
        apt update && \
        apt install -y --no-install-recommends \
            figlet \
            nano \
            unzip \
            zip; \
    echo "Installing Bun to $LARAVEL_USER..."; \
        su - $LARAVEL_USER -c 'curl -fsSL https://bun.sh/install | bash'; \
    echo "Install Required php extensions..."; \
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
            redis; \
    \
    echo "Install PHP intl..."; \
        docker-php-ext-configure intl && \
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