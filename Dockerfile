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
      pdo_pgsql  \
      && \
    cd /ext/php-memcached-3.4.0 && phpize && ./configure && make -j$(nproc) && make install && docker-php-ext-enable memcached && \
    cd /ext/php-spx-0.4.22 && phpize && ./configure && make -j$(nproc) && make install && docker-php-ext-enable spx && \
    rm -rf /ext && apk del && apk del \
      shadow \
      icu-dev \
      autoconf \
      zlib-dev \
      libzip-dev \
      libpq-dev \
      build-base \
      libpng-dev \
      libwebp-dev \
      freetype-dev \
      libmemcached-dev \
      libjpeg-turbo-dev \
      && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

WORKDIR /var/www

USER www-data:www-data

CMD ["php-fpm"]
