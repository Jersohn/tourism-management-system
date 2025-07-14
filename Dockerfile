FROM php:5.6-apache

# Install git and required dependencies
RUN apt-get update && apt-get install -y \
    git \
    && docker-php-ext-install mysqli pdo pdo_mysql gd zip

# Enable Apache rewrite module
RUN a2enmod rewrite

# Clone your GitHub repository
ARG GITHUB_REPO
RUN git clone https://github.com/Jersohn/tourism-management-system.git /var/www/html

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80