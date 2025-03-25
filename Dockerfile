FROM php:8.4.5-apache

ENV DEBIAN_FRONTEND=noninteractive
USER root

RUN echo "display_errors=On" > /usr/local/etc/php/conf.d/display_errors.ini

RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
            curl \
            libmemcached-dev \
            libz-dev \
            libpq-dev \
            libjpeg-dev \
            libpng-dev \
            libfreetype6-dev \
            libssl-dev \
            imagemagick \
            libmagickwand-dev \
            libonig-dev \
            libzip-dev; \
    rm -rf /var/lib/apt/lists/*

RUN pecl install imagick && docker-php-ext-enable imagick
RUN pecl install mongodb && docker-php-ext-enable mongodb
RUN pecl install apcu && docker-php-ext-enable apcu

RUN set -eux; \
    docker-php-ext-install pdo pdo_mysql mysqli zip; \
    docker-php-ext-configure gd \
            --with-freetype \
            --with-jpeg; \
    docker-php-ext-install gd iconv mbstring; \
    docker-php-ext-enable gd; \
    php -r 'var_dump(gd_info());'

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN a2enmod rewrite

RUN apt-get -qq update && apt-get install -y net-tools

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
