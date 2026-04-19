FROM php:7.4-fpm-alpine
#php-7.4-alpine-dev
ARG UID=1000

#ADD conf/* /usr/local/etc/php-fpm.d/
ADD ini/* /usr/local/etc/php/conf.d/
ADD ext/* /ext

RUN apk --no-cache add shadow && \
    usermod --uid $UID www-data \
      && \
    apk update  \
      && \
    apk --no-cache add \
      git \
      curl \
      icu-dev \
      autoconf \
      libpq-dev \
      build-base \
      libressl-dev \
      zlib-dev \
      libpng-dev \
      libzip-dev \
      libxml2-dev \
      libwebp-dev \
      libmemcached-dev \
      freetype-dev \
      libjpeg-turbo-dev \
      && \
    pecl install --onlyreqdeps --force \
      apcu \
      redis \
      xdebug-3.0.0 \
      && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install -j$(nproc)  \
      gd \
      pdo \
      zip \
      intl \
      pgsql \
      pcntl \
      opcache \
      pdo_pgsql \
      && \
    docker-php-ext-enable \
      gd \
      apcu \
      redis \
      xdebug \
      pdo_pgsql \
      && \
    docker-php-ext-configure /ext/php-spx-0.4.22 && \
    docker-php-ext-configure /ext/php-memcached-3.4.0 && \
    docker-php-ext-install -j$(nproc) /ext/php-spx-0.4.22 /ext/php-memcached-3.4.0 && \
    docker-php-ext-enable spx memcached && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    apk del \
      shadow \
      autoconf \
      build-base \
      && \
    rm -rf /ext /var/cache/apk/* /tmp/* /var/tmp/*

WORKDIR /var/www

USER www-data:www-data
