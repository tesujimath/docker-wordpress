#!/bin/sh
#
# bootstrap the WordPress container, idempotently

set -ex

# Download and unpack WordPress from tarball, if we don't already have it.
# Note that we don't check if an existing version matches $WORDPRESS_VERSION.
# Upgrades are handled within WordPress itself.
if test -f /var/www/html/${WORDPRESS_CORE:-wordpress}/wp-activate.php; then
    echo >&2 "WordPress already downloaded"
else
    cd /var/www/html
    curl -o wordpress.tar.gz -fSL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz
    echo "${WORDPRESS_SHA1} *wordpress.tar.gz" | sha1sum -c -
    rm -rf ${WORDPRESS_CORE:-wordpress}
    mkdir -p ${WORDPRESS_CORE:-wordpress}
    # upstream tarballs include ./wordpress/ which we strip
    tar -xzf wordpress.tar.gz --strip-components=1 -C ${WORDPRESS_CORE:-wordpress}
    rm -f wordpress.tar.gz
    chown -R www-data:www-data /var/www/html
fi

wait-for-database-ready

# Use WP-CLI to install WordPress itself, if required
su -s /bin/sh -c "wp --path=/var/www/html/${WORDPRESS_CORE:-wordpress} core is-installed || wp --path=/var/www/html/${WORDPRESS_CORE:-wordpress} core install --url=\"${WORDPRESS_URL}\" --title=\"${WORDPRESS_TITLE}\" --admin_user=\"${WORDPRESS_ADMIN_USER}\" --admin_password=\"${WORDPRESS_ADMIN_PASSWORD}\" --admin_email=\"${WORDPRESS_ADMIN_EMAIL}\"" www-data

# setup theme, plugins, options, etc.
su -s /bin/sh -c wp-post-install-setup www-data

exec "$@"
