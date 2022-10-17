FROM php:8.1-fpm

# Copy composer.lock and composer.json
COPY app/composer.lock  app/composer.json /var/www/

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    nodejs \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    libpng-dev \
    git \
    supervisor  \
    curl
RUN apt-get update; \
    # Imagick extension and others ext
    apt-get install -y libmagickwand-dev; \
    apt-get install -y libgmp-dev; \
    pecl install imagick; \
    docker-php-ext-enable imagick; \
    docker-php-ext-enable mbstring; \
    docker-php-ext-enable zip; \
    docker-php-ext-enable exif; \
    docker-php-ext-enable pcntl; \
    docker-php-ext-enable gd; \
    # Success
    true
	
#instalar php version español
RUN apt-get install -y locales locales-all
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
#RUN docker-php-ext-install gd
RUN docker-php-ext-configure gd --enable-gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/

# install all the dependencies and enable PHP modules
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
      procps \
      nano \
      git \
      unzip \
      libicu-dev \
      zlib1g-dev \
      libxml2 \
      libxml2-dev \
      libreadline-dev \
      cron \
      sudo \
      zip \
      libzip-dev \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure intl \
    && docker-php-ext-install \
      sockets \
      intl \
      gmp \
      pdo_mysql \
      gd \
      opcache \
      zip \
    && rm -rf /tmp/* \
    && rm -rf /var/list/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
	
# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# Install node
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - 
RUN apt-get install -y nodejs
RUN chmod 644 /etc/mysql/my.cnf
# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY app/ /var/www

# Copy existing application directory permissions
COPY --chown=www:www app/ /var/www
RUN chown -R www:www /var/www


# Make supervisor log directory
RUN mkdir -p -m 777 /var/log/supervisor/

# Copy local supervisord.conf to the conf.d directory
ADD supervisor/supervisord.conf /etc/supervisor/supervisord.conf

# Change current user to www
USER www

# Expose port 9000 
EXPOSE 9000
# Start supervisord and start php-fpm server
#CMD ["php-fpm"]
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
#CMD ["/usr/bin/supervisord", "-c",  "/etc/supervisor/supervisord.conf"]
#CMD ["/var/www/entrypoint.sh"]

