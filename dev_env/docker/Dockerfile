FROM php:7.3.0-apache

#-a run non-interactive. Suppresses prompts and just accepts defaults automatically.
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    iputils-ping \
    libicu-dev \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    libxml2-dev \
    libbz2-dev \
    libjpeg62-turbo-dev \
    librabbitmq-dev \
    libzip-dev \
    libxslt-dev \
    curl \
    git \
    unzip \
  && rm -rf /var/lib/apt/lists/*


#-a make sure custom log directories exist
RUN mkdir /usr/local/log; \
    mkdir /usr/local/log/apache2; \
    mkdir /usr/local/log/php; \
    chmod -R ug+w /usr/local/log

# Install various PHP extensions
RUN docker-php-ext-configure bcmath --enable-bcmath \
  && docker-php-ext-configure pcntl --enable-pcntl \
  && docker-php-ext-configure pdo_mysql --with-pdo-mysql \
  && docker-php-ext-configure pdo_pgsql --with-pgsql \
  && docker-php-ext-configure mbstring --enable-mbstring \
  && docker-php-ext-configure soap --enable-soap \
  && docker-php-ext-configure xsl --enable-xsl \
  && docker-php-ext-install \
    bcmath \
    intl \
    mbstring \
    mysqli \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    soap \
    sockets \
    zip \
    xsl \
  && docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2 \
  && docker-php-ext-install gd \
  && docker-php-ext-install opcache \
  && docker-php-ext-enable opcache \
  && pecl install amqp \
  && docker-php-ext-enable amqp


# ICU - intl
# Debian is out of date, this is the latest - so build from source, unless a better alternative exists(?)
# RUN curl -sS -o /tmp/icu.tar.gz -L https://github.com/unicode-org/icu/releases/download/release-67-1/icu4c-67_1-src.tgz \
# 	&& tar -zxf /tmp/icu.tar.gz -C /tmp \
# 	&& cd /tmp/icu/source \
# 	&& ./configure --prefix=/usr/local \
# 	&& make \
# 	&& make install

# RUN docker-php-ext-configure intl \
#     --with-icu-dir=/usr/local \
#   && docker-php-ext-install intl


# Install the php memcached extension
# RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/v3.1.3.tar.gz" \
#   && mkdir -p memcached \
#   && tar -C memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
#   && ( \
#     cd memcached \
#     && phpize \
#     && ./configure \
#     && make -j$(nproc) \
#     && make install \
#   ) \
#   && rm -r memcached \
#   && rm /tmp/memcached.tar.gz \
#   && docker-php-ext-enable memcached

# Copy opcache configration
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Copy timezone configration
COPY ./timezone.ini /usr/local/etc/php/conf.d/timezone.ini

# Set timezone
RUN rm /etc/localtime \
  && ln -s /usr/share/zoneinfo/Europe/London /etc/localtime \
  && "date"


# Short open tags fix
COPY ./custom-php.ini /usr/local/etc/php/conf.d/custom-php.ini


# XDebug
# This value must match the name of the 'server' created in PhpStorm for XDebug purposes
# https://confluence.jetbrains.com/display/PhpStorm/Debugging+PHP+CLI+scripts+with+PhpStorm#DebuggingPHPCLIscriptswithPhpStorm-2.StarttheScriptwithDebuggerOptions
# ENV PHP_IDE_CONFIG "serverName=Docker"



#-a Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /usr/local/log/apache2

#-a Configure apache mods
RUN a2enmod rewrite 

#-a Add ServerName parameter
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/servername.conf
RUN a2enconf servername

#-a Update the default apache site with the config we created.
RUN { \
        echo '<VirtualHost *:80>'; \
        echo '    ServerAdmin your_email@example.com'; \
        echo '    DocumentRoot /var/www/html'; \
        echo '    <Directory /var/www/html/>'; \
        echo '        Options Indexes FollowSymLinks MultiViews'; \
        echo '        AllowOverride All'; \
        echo '        Order deny,allow'; \
        echo '        Allow from all'; \
        echo '    </Directory>'; \
        echo '    ErrorLog /usr/local/log/apache2/error.log'; \
        echo '    CustomLog /usr/local/log/apache2/access.log combined' ; \
        echo '</VirtualHost>'; \
    } > /etc/apache2/sites-enabled/000-default.conf

# Composer
ENV COMPOSER_HOME /var/www/.composer


RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/bin \
    --filename=composer \
  && composer self-update

# RUN chown -R www-data:www-data /var/www/ \
#   && mkdir -p $COMPOSER_HOME/cache \
#   && composer global require "hirak/prestissimo:^0.3" \
#   && rm -rf $COMPOSER_HOME/cache \
#   && mkdir -p $COMPOSER_HOME/cache


RUN rm -rf /var/lib/apt/lists/*

VOLUME $COMPOSER_HOME

#-a
EXPOSE 80
