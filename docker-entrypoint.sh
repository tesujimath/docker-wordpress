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

# Install latest version of WP-CLI, only if we don't already have it.
# Upgrades are handled by `wp cli update`.
if test -f /usr/local/bin/wp; then
    echo >&2 "WP-CLI already downloaded"
else
    curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp
    chmod 755 /usr/local/bin/wp
fi

wait-for-database-ready

# Use WP-CLI to install WordPress itself
su -s /bin/sh -c "wp core install --path=/var/www/html/wordpress --url=\"${WORDPRESS_URL}\" --title=\"${WORDPRESS_TITLE}\" --admin_user=\"${WORDPRESS_ADMIN_USER}\" --admin_password=\"${WORDPRESS_ADMIN_PASSWORD}\" --admin_email=\"${WORDPRESS_ADMIN_EMAIL}\"" www-data

# Use WP-CLI to install and activate the desired theme
su -s /bin/sh -c "wp theme install --path=/var/www/html/wordpress --activate \"${WORDPRESS_THEME}\"" www-data

# Use WP-CLI to install and activate required plugins
test -n "$WORDPRESS_PLUGINS" && for plugin in $WORDPRESS_PLUGINS; do
    su -s /bin/sh -c "wp plugin install --path=/var/www/html/wordpress --activate $plugin" www-data
done
# and local plugins from zipfiles
test -d "$WORDPRESS_PLUGINS_DIR" && for plugin in `ls $WORDPRESS_PLUGINS_DIR`; do
    su -s /bin/sh -c "wp plugin install --path=/var/www/html/wordpress --activate $WORDPRESS_PLUGINS_DIR/$plugin" www-data
done

exec "$@"
