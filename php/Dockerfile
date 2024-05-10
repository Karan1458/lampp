FROM php:8.3-fpm-alpine

# Install PHP extensions
RUN apk add --no-cache icu-dev libzip-dev zip libpng-dev gmp-dev 
RUN docker-php-ext-install mysqli pdo pdo_mysql zip bcmath gmp gd
RUN docker-php-ext-configure intl && docker-php-ext-install intl

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

