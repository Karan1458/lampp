#!/bin/sh

# Set the correct permissions
chown -R www-data:www-data /var/www/projects

# Fix Files 
find /var/www/projects -type f -exec chmod 644 {} \; 

# Fix Directories
find /var/www/projects -type d -exec chmod 755 {} \; 
