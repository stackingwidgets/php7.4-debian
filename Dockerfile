FROM php:7.4-apache

LABEL name="com.stackinwidgets.php7-4"

LABEL version="1.0.0"

ENV DEBIAN_FRONTEND noninteractive
ENV PHP_INI_DATE_TIMEZONE='UTC'
ENV PHP_MEMORY_LIMIT=768M
ENV PHP_MAX_UPLOAD=128M
ENV PHP_MAX_EXECUTION_TIME=300

RUN apt-get update && apt-get upgrade -y && apt-get install -q -y \
    ca-certificates \
    build-essential  \
    software-properties-common \
    htop \
    g++ \
    tcl \
    nano \
    dos2unix \
    libonig-dev \
    git \
    acl \
    gnupg2 \
    dialog \
    zip \
    unzip \
    sudo \
    apache2 \
    libapache2-mod-security2 \
    modsecurity-crs \
    curl \
    tcl \
    cron \
    tidy \
    sysvbanner \
    csstidy \
    zlib1g-dev \
    libcurl4-openssl-dev \
    libaprutil1-dev \
    libssl-dev \
    libicu-dev \
    libldap2-dev \
    libxml2-dev \
    imagemagick \
    ghostscript \
    libmagickwand-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev \
    wget \
    libmemcached-dev \
    libz-dev \
    libmemcachedutil2 \
    libpq-dev \
    libxpm4 \
    libjpeg-dev \
    libjpeg62-turbo \
    libfreetype6-dev \
    mariadb-client \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \
    && sudo apt-get clean

RUN docker-php-source extract \
    && docker-php-ext-configure mysqli --with-mysqli=mysqlnd \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure bcmath \
    && docker-php-ext-install bcmath exif intl pcntl ftp mbstring xml gd soap opcache \
    && docker-php-ext-enable opcache  \
    && docker-php-ext-configure gd \
    --with-gd --with-webp-dir --with-jpeg-dir \
    --with-png-dir --with-zlib-dir --with-xpm-dir --with-freetype \
    --enable-gd-native-ttf \
    && docker-php-ext-install gd \
    && for i in $(seq 1 3); do pecl install -o redis && s=0 && break || s=$? && sleep 1; done; (exit $s) \
    && docker-php-ext-enable redis \
    \
    && for i in $(seq 1 3); do echo no | pecl install -o memcached && s=0 && break || s=$? && sleep 1; done; (exit $s) \
    && docker-php-ext-enable memcached \
    && pecl install imagick -y \
    && docker-php-ext-enable imagick

RUN mkdir -p $COMPOSER_HOME \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN { \
    echo 'opcache.memory_consumption=800M'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=10000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
    echo 'expose_php = Off'; \
    echo 'file_uploads = On'; \
    } > /usr/local/etc/php/conf.d/stackingwidgets-settings.ini

RUN printf "no\n" | pecl install apcu

RUN pecl install apcu_bc-1.0.3 \
    && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
    && docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini

RUN a2enmod setenvif \
    headers \
    security2 \
    deflate \
    filter \
    expires \
    rewrite \
    include \
    ext_filter

EXPOSE 80

CMD ["apache2-foreground"]

