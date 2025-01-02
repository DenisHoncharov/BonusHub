FROM php:8.4-fpm

RUN apt-get update && apt-get install -y --no-install-recommends \
	acl \
	file \
	gettext \
	git \
    nano \
    libicu-dev \
    libzip-dev \
	&& rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	docker-php-ext-install \
		intl \
		opcache \
		zip \
        pdo_mysql \
	;

RUN chown -R www-data:www-data /var/www/html

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

USER root

RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash
RUN apt-get install symfony-cli

#nvm install and node install
# Установка nvm
ENV NVM_DIR /root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash

# Установка Node.js
RUN bash -c ". $NVM_DIR/nvm.sh && nvm install 14.17.0 && nvm install node && nvm alias default node && nvm use default"

# Добавляем nvm в PATH
RUN echo "export NVM_DIR=$NVM_DIR" >> /root/.bashrc \
    && echo "[ -s \"$NVM_DIR/nvm.sh\" ] && \\. \"$NVM_DIR/nvm.sh\"" >> /root/.bashrc \
    && echo "[ -s \"$NVM_DIR/bash_completion\" ] && \\. \"$NVM_DIR/bash_completion\"" >> /root/.bashrc


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
########################### Backend DEV############################
#FROM registry.devlabs.me/devops/hub/php-fpm:7.3-debug-latest as backend
#FROM registry.gitlab.com/pfe-team4/pfe/php-fpm:7.3-debug-latest as backendFROM php:8.0-fpm-buster AS backend#deps
#RUN apt-get update && apt-get install -y \ libfreetype6-dev \ libjpeg62-turbo-dev \ libpng-dev \ libzip-dev \ unzip \ pdftk-java \ imagemagick \ texlive-extra-utils \ && docker-php-ext-install bcmath \ && docker-php-ext-configure gd --with-freetype --with-jpeg \ && docker-php-ext-install -j$(nproc) gd pdo_mysql zip \
#composer
#COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
#RUN apt-get update --allow-releaseinfo-change && apt-get -y install git
#RUN mkdir -p /usr/share/man/man1
#WORKDIR /home
#COPY ./_docker/php.ini /usr/local/etc/php/php.ini
#COPY ./backend/composer.json .
#COPY ./backend/composer.lock .
#COPY ./backend/app/console/migrate.sh ./app/console/migrate.sh
#RUN composer install --no-interaction --prefer-dist
#COPY ./backend .
#COPY ./web/assets /home/web/assets
#COPY ./web/pdf /home/web/pdf
#COPY ./web/upload /home/web/upload
#COPY ./web/index.php /home/web/index.php
#RUN chmod 777 /home/app/runtime -R
#RUN chmod 777 /home/web/assets -R
#RUN chmod 777 /home/web/pdf -R
#RUN chmod 777 /home/web/upload -R
#RUN mkdir -p /home/app/upload
#RUN chmod 777 /home/app/upload -R
#RUN ./vendor/bin/codecept build -c tests/codeception.yml
#FROM backend AS queue
#RUN apt-get update && apt-get -y install supervisor
#COPY ./_docker/supervisor.conf.d /etc/supervisor/conf.d