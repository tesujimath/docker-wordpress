ARG WORDPRESS_HUSK_RELEASE=7.3-fpm-alpine-1
FROM tesujimath/wordpress-husk:$WORDPRESS_HUSK_RELEASE
ARG WORDPRESS_HUSK_RELEASE

LABEL maintainer "Simon Guest <simon.guest@tesujimath.org>"
LABEL WORDPRESS_HUSK_RELEASE="$WORDPRESS_HUSK_RELEASE"

RUN apk add --no-cache curl git rsync msmtp && \
    ln -sf /usr/bin/msmtp /usr/sbin/sendmail

COPY docker-entrypoint.sh wait-for-database-ready wp-post-install-setup /usr/local/bin/

# get latest version of WP-CLI
RUN curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp && \
    chmod 0755 /usr/local/bin/*

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
