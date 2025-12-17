FROM php:7.4-fpm

ARG UID=1000

#ADD conf/* /usr/local/etc/php-fpm.d/
ADD ini/* /usr/local/etc/php/conf.d/
ADD ext/* /ext

RUN usermod --uid $UID www-data \
      && \
    apt update  \
      && \
    apt-get install -y --no-install-recommends \
      curl \
      libpq-dev \
      libssl-dev \
      zlib1g-dev \
      libpng-dev \
      libzip-dev \
      libxml2-dev \
      libwebp-dev \
      libmemcached-dev \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
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
    docker-php-ext-configure /ext/php-spx-0.4.22 && \
    docker-php-ext-configure /ext/php-memcached-3.4.0 && \
    docker-php-ext-install -j$(nproc) /ext/php-spx-0.4.22 /ext/php-memcached-3.4.0 && \
    docker-php-ext-enable spx memcached && \
    apt autoremove -y && apt clean && rm -rf /ext /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

WORKDIR /var/www

USER www-data:www-data
