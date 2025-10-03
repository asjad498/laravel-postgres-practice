FROM php:8.2-apache

# Install system dependencies including pg_isready AND libpq-dev
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    nano \
    postgresql-client \     # For pg_isready in startup script
    libpq-dev \             # 👈 Critical: For PHP PostgreSQL extension (this was missing!)
    && rm -rf /var/lib/apt/lists/*

# Install required PHP extensions (PostgreSQL + Laravel deps)
RUN docker-php-ext-install pdo_pgsql pgsql mbstring exif pcntl bcmath gd

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

# Create storage directories
RUN mkdir -p storage/logs \
    && mkdir -p storage/framework/sessions \
    && mkdir -p storage/framework/cache \
    && mkdir -p storage/framework/views

# Set ownership and permissions
RUN chown -R www-data:www-data storage
RUN chmod -R 775 storage

# Set document root to /public
RUN sed -i 's|/var/www/html|/var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# Copy Apache config
COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf

# Copy startup script
COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Use it as entrypoint
CMD ["/usr/local/bin/start.sh"]