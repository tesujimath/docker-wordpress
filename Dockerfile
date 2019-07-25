ARG WORDPRESS_HUSK_RELEASE=7.3-fpm-alpine-1
FROM tesujimath/wordpress-husk:$WORDPRESS_HUSK_RELEASE
ARG WORDPRESS_HUSK_RELEASE

LABEL maintainer "Simon Guest <simon.guest@tesujimath.org>"
LABEL WORDPRESS_HUSK_RELEASE="$WORDPRESS_HUSK_RELEASE"

RUN apk add --no-cache curl git rsync

#COPY docker-entrypoint.sh /usr/local/bin

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
