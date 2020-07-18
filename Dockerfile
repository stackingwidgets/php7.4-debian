FROM php:7.3-apache

LABEL name="com.stackinwidgets.php7-4"

LABEL version="1.0.0"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

RUN apt-get install -y git

RUN docker-php-ext-install pdo pdo_mysql

EXPOSE 80

RUN a2enmod rewrite

CMD ["apache2-foreground"]

