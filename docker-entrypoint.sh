#!/bin/sh
#
# bootstrap the WordPress container, idempotently

set -ex

# Download and unpack WordPress from tarball, if we don't already have it.
# Note that we don't check if an existing version matches $WORDPRESS_VERSION.
# Upgrades are handled within WordPress itself.
if test -f /var/www/html/wordpress/wp-activate.php; then
    echo >&2 "WordPress already downloaded"
else
    cd /var/www/html
    curl -o wordpress.tar.gz -fSL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz
    echo "${WORDPRESS_SHA1} *wordpress.tar.gz" | sha1sum -c -
    # upstream tarballs include ./wordpress/ so this gives us /var/www/html/wordpress
    tar -xzf wordpress.tar.gz
    rm -f wordpress.tar.gz
    chown -R www-data:www-data /var/www/html
fi

wait-for-database-ready

# Use WP-CLI to install WordPress itself, if required
su -s /bin/sh -c "wp --path=/var/www/html/wordpress core is-installed || wp --path=/var/www/html/wordpress core install --url=\"${WORDPRESS_URL}\" --title=\"${WORDPRESS_TITLE}\" --admin_user=\"${WORDPRESS_ADMIN_USER}\" --admin_password=\"${WORDPRESS_ADMIN_PASSWORD}\" --admin_email=\"${WORDPRESS_ADMIN_EMAIL}\"" www-data

# setup theme, plugins, options, etc.
su -s /bin/sh -c wp-post-install-setup www-data

exec "$@"
