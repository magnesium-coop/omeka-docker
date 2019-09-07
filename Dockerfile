FROM php:5.6-apache

RUN a2enmod rewrite

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update && apt-get -qq -y --no-install-recommends install \
    curl \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libjpeg-dev \
    libmemcached-dev \
    zlib1g-dev \
    imagemagick

# install the PHP extensions we need
RUN docker-php-ext-install -j$(nproc) iconv mcrypt \
    pdo pdo_mysql mysqli gd
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install exif && \
    docker-php-ext-enable exif

RUN curl -J -L -s -k \
    'https://github.com/omeka/Omeka/releases/download/v2.7/omeka-2.7.zip' \
    -o /var/www/omeka.zip \
&&  unzip -q /var/www/omeka.zip -d /var/www/ \
&&  rm /var/www/omeka.zip \
&&  rm -rf /var/www/html \
&&  mv /var/www/omeka-2.7 /var/www/html \
&&  chown -R www-data:www-data /var/www/html

COPY ./plugins/*.zip /var/www/html/plugins/
RUN unzip /var/www/html/plugins/AdminImages.zip -d /var/www/html/plugins/
RUN unzip /var/www/html/plugins/CollectionTree-2.1.zip -d /var/www/html/plugins/
RUN unzip /var/www/html/plugins/OmekaApiImport.zip -d /var/www/html/plugins/
RUN unzip /var/www/html/plugins/ItemRelations-2.1.zip -d /var/www/html/plugins/
RUN unzip /var/www/html/plugins/ShortcodeCarousel-1.0.1.zip -d /var/www/html/plugins/


COPY ./config/db.ini /var/www/html/db.ini
COPY ./config/.htaccess /var/www/html/.htaccess
COPY ./config/imagemagick-policy.xml /etc/ImageMagick/policy.xml
COPY ./config/config.ini /var/www/html/application/config/config.ini
COPY ./config/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

VOLUME /var/www/html

CMD ["apache2-foreground"]
