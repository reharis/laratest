# Set the base image
FROM php:8.3-apache

# Install dependencies and SQLite extension
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    unzip \
    git \
    libsqlite3-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_sqlite

# Install Node.js and npm
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Set the working directory
WORKDIR /var/www/html

# Copy the application files
COPY . .

# Copy the custom Apache configuration file
COPY apache.conf /etc/apache2/sites-available/000-default.conf


# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader

# Install npm dependencies and build assets
RUN npm install
RUN npm run build

RUN mkdir -p /var/www/database
RUN touch /var/www/database/database.sqlite

RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chown -R www-data:www-data /var/www/database \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Enable Apache Rewrite Module
RUN a2enmod rewrite

# Expose the port
EXPOSE 80

# Start the Apache server
CMD ["bash", "-c", "php artisan migrate --force && apache2-foreground"]
