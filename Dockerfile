FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    nano \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Enable Apache mods
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy code
COPY . .

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install dependencies
RUN composer install --optimize-autoloader --no-dev

# Create storage directories if not exists
RUN mkdir -p storage/logs \
    && mkdir -p storage/framework/sessions \
    && mkdir -p storage/framework/cache \
    && mkdir -p storage/framework/views

# Set ownership to www-data (Apache user)
RUN chown -R www-data:www-data storage

# Set permissions
RUN chmod -R 775 storage

# Set document root to /public
RUN sed -i 's|/var/www/html|/var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# Copy Apache virtual host config
COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf

# Expose port (optional; Render uses $PORT)
EXPOSE $PORT

# Start Apache
CMD ["apachectl", "-D", "FOREGROUND"]