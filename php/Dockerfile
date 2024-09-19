FROM php:8.3-fpm-alpine


# Arguments defined in docker-compose.yml
ARG user
ARG UID
ARG GID

# Install PHP extensions
RUN apk add --no-cache autoconf libtool make icu-dev libzip-dev zip libpng-dev gmp-dev su-exec
RUN docker-php-ext-install mysqli pdo pdo_mysql zip bcmath gmp gd exif
RUN docker-php-ext-configure intl && docker-php-ext-install intl
#RUN docker-php-ext-configure gd --with-jpeg && \docker-php-ext-install gd
RUN docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-install pcntl

    

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


#Install mhSendmail
COPY --from=tkotosz/mhsendmail:0.2.0 /usr/bin/mhsendmail /usr/local/bin/


# Remove if exists 
RUN if getent passwd ${UID} >/dev/null; then \
    deluser $(getent passwd ${UID} | cut -d: -f1); fi

RUN if getent group ${GID} >/dev/null; then \
    delgroup $(getent group ${GID} | cut -d: -f1); fi


# Create system user to run Composer and Artisan Commands
RUN addgroup --system --gid ${GID} ${user}
RUN adduser --system --disabled-password --home /home/${user} \
        --uid ${UID} ${user}

#RUN adduser -G www-data,root -u $UID --home /home/$user -s $user
RUN addgroup ${user} www-data
RUN addgroup ${user} root

RUN mkdir -p /home/${user}/.composer & \
    chown -R ${user}:${user} /home/${user}

# Set the correct permissions
#COPY fix-permissions.sh /home/${user}/scripts/fix-permissions.sh
#RUN chmod +x /home/${user}/scripts/fix-permissions.sh
#RUN /home/${user}/scripts/fix-permissions.sh


# Set the user
#USER $user


# Set working directory
WORKDIR /var/www/html

#CMD ["/home/${user}/scripts/fix-permissions.sh"]
CMD ["/usr/local/sbin/php-fpm", "--allow-to-run-as-root"]

#ENTRYPOINT ["su-exec", "nobody", "/usr/local/sbin/php-fpm", "--nodaemonize", "--force-stderr"]

