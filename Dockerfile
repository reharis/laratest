# Set the base image
FROM php:8.3-fpm

# Install dependencies and SQLite extension
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    unzip \
    git \
    libsqlite3-dev \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_sqlite

# Install Node.js and npm
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Set the working directory
WORKDIR /var/www

# Copy the application files
COPY . .

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Laravel dependencies
RUN composer install

# Install npm dependencies and build assets
RUN npm install && npm run build

# Set permissions (if needed)
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Expose the port
EXPOSE 9000

# Start the PHP-FPM server
CMD ["php-fpm"]
