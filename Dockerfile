# Defaulti
#ARG TIMEZONE=America/Chicago
FROM php:5.6-fpm
ARG TIMEZONE=America/Chicago

LABEL com.singlehop.maintainer="Singlehop <sthakkel@singlehop.com>"
LABEL version="1.0"
LABEL com.singlehop.widget.resource="application"

ARG TIMEZONE

# Github keys rbac-connect-bundle
RUN mkdir -p -m 0700 /root/.ssh
#COPY keys/id_rsa_rbac-connect-bundle /root/.ssh
COPY keys/id_rsa_rbac-connect-bundle.pub /root/.ssh
COPY keys/config.ssh /root/.ssh/config
RUN chmod 0600 -R /root/.ssh/*

# Install required dependecies for Widget App, properly formatted
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
        libpq-dev \
        libmcrypt-dev \
        libxslt-dev \
        git \
        curl \
        ssh \
    && docker-php-ext-install -j$(nproc) \
        iconv \
        mcrypt \
        pdo_pgsql \
        zip \
        bcmath \
        xsl \
    && pecl channel-update pecl.php.net \
    && pecl install \
        apcu-4.0.11 \
        redis \
        xdebug-2.5.5 \
    && docker-php-ext-enable \
        apcu \
        opcache \
        redis \
        xdebug \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 2hrs to figure this out
RUN ssh-keyscan -H github.com >> ~/.ssh/known_hosts

# Install PHP Composer
RUN ["/bin/bash", "-c", "set -o pipefail && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer"]
# Test install
RUN composer --version

# Set Timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini
RUN "date"

# XDEBUG Needs to be disabled in production, stop breaking container cache
RUN printf 'xdebug.remote_enable = %s\n' 1 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN printf 'xdebug.remote_host = %s\n' 10.254.254.254 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN printf 'xdebug.remote_port = %s\n' 9000 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN printf 'xdebug.remote_log = %s\n' /usr/local/var/log/fpm.xdebug.log >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Performance configs http://symfony.com/doc/2.8/performance.html
RUN echo 'opcache.enable=On' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
RUN echo 'opcache.max_wasted_percentage=10' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
RUN echo 'opcache.max_accelerated_files=20000' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
RUN echo 'opcache.interned_strings_buffer=16' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
# Not needed for >PHP5.6
RUN echo 'opcache.fast_shutdown=1' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
RUN echo 'opcache.log_verbosity_level=2' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
RUN echo 'opcache.error_log=/usr/local/var/log/opcache.log' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
RUN echo 'opcache.memory_consumption=256' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
#RUN echo 'opcache.validate_timestamps=0' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini # Production only
RUN echo 'realpath_cache_size=4096K' >> /usr/local/etc/php/conf.d/realpath.ini
RUN echo 'realpath_cache_ttl=600' >> /usr/local/etc/php/conf.d/realpath.ini

# Perfomance Cache fix
RUN echo 'apc.shm_size=128M' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini

ADD scripts/start.sh /start.sh
RUN chmod u+x /start.sh
ADD scripts/symfony_environment.sh /etc/profile.d/symfony_environment.sh

WORKDIR /var/www/html

ENTRYPOINT ["/start.sh"]
