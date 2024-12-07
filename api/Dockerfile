# Utiliser l'image officielle PHP 8.3 avec FPM et extensions nécessaires
FROM php:8.2-fpm

# Installer des dépendances nécessaires pour Symfony et Mercure
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libzip-dev \
    zip \
    git \
    curl \
    unzip \
    && docker-php-ext-install pdo pdo_mysql zip

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Installer les extensions nécessaires à Symfony et Mercure
RUN pecl install apcu \
    && docker-php-ext-enable apcu

# Installer Node.js et Yarn pour gérer les assets si nécessaire
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn

# Copier les fichiers de l'application dans le conteneur
WORKDIR /var/www/symfony
COPY . /var/www/symfony

# Installer les dépendances Symfony avec Composer
RUN COMPOSER_ALLOW_SUPERUSER=1 composer install --no-scripts --no-interaction --prefer-dist

# Configurer les permissions
RUN chown -R www-data:www-data /var/www/symfony

# Exposer le port PHP-FPM
EXPOSE 9000

# Commande de démarrage de PHP-FPM
CMD ["php-fpm"]