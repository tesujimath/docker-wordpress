A WordPress container, which downloads and installs WordPress when the container
is started.  It is based on my
[wordpress-husk](https://github.com/tesujimath/docker-wordpress-husk) image,
which itself borrows heavily from the
[official docker WordPress images](https://github.com/docker-library/wordpress),
and which I'm hoping will be superseded by something from that project.

It also supports sending email, using msmtp.  Simply mount your `msmtprc` into
the container at `/etc/msmtprc`.

When this container is started for the first time, it performs the following steps:

1. download and unpack WordPress
2. wait for the MySQL database to be ready
3. use WP-CLI to install the WordPress
4. install and activate the WordPress theme
5. install and activate WordPress plugins, both from the main repo and local zipfiles
6. set options from all files found in an options directory

When the container is subsequently started, these steps all detect that nothing
is required to be done.

## Usage

The WordPress configuration must be mounted into the container explicitly.  See
the directory structure (below).  The main WordPress sub-directory of
`/var/www/html` is `${WORDPRESS_CORE}`, which must not have a leading nor
trailing slash, and which defaults to `wordpress` is not set.

Additionally, the following environment variables are required to be defined.

The WordPress download requires the following environment variables:

| Variable            | Description                                              |
|---------------------|----------------------------------------------------------|
| `WORDPRESS_VERSION` | Version of WordPress to download and install, e.g. 5.2.2 |
| `WORDPRESS_SHA1`    | SHA1 checksum of wordpress.tar.gz for this version       |

The WordPress database install requires the following, which are all passed
through to `wp core install` as the named option.

| Variable                   | Option             |
|----------------------------|--------------------|
| `WORDPRESS_URL`            | `--url`            |
| `WORDPRESS_TITLE`          | `--title`          |
| `WORDPRESS_ADMIN_USER`     | `--admin_user`     |
| `WORDPRESS_ADMIN_PASSWORD` | `--admin_password` |
| `WORDPRESS_ADMIN_EMAIL`    | `--admin_email`    |

The theme installation and activation requires the following:

| Variable          | Description                              |
|-------------------|------------------------------------------|
| `WORDPRESS_THEME` | Theme name, passed to `wp theme install` |

Plugin installation and activation  requires the following:

| Variable                | Description                                                     |
|-------------------------|-----------------------------------------------------------------|
| `WORDPRESS_PLUGINS`     | Space-separated list of plugins to install and activate         |
| `WORDPRESS_PLUGINS_DIR` | Directory of additional zipfile plugins to install and activate |


Option setting requires the following:

| Variable                | Description                       |
|-------------------------|-----------------------------------|
| `WORDPRESS_OPTIONS_DIR` | Directory containing option files |

The option file syntax is line oriented, `name=value`, where value may not
contain a double quote (use `&#34`; instead).  Any line starting with a hash is
ignored.

Additionally, the following environment variables are required explicitly, and
separately from `wp-config.php`, so that the `wait-for-database-ready` script
can connect.  They format is as in `wp-config.php`

| Variable      |
|---------------|
| `DB_HOST`     |
| `DB_NAME`     |
| `DB_USER`     |
| `DB_PASSWORD` |


## Directory Structure

The core WordPress directory is `/var/www/html/${WORDPRESS_CORE:-wordpress}`.

The WordPress configuration should be mounted into the container at
`/var/www/html/wp-config.php`.

## Recommended WordPress configuration

This author suggests using something like `/content` as the content directory,
for which the following configuration is required in `wp-config.php`:

```
/** Absolute path to the WordPress directory, to match ${WORDPRESS_CORE:-wordpress}. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname( __FILE__ ) . '/wordpress/' );
}

/** Relocate content directory from to /content. */
define( 'WP_CONTENT_URL', '/content' );
define( 'WP_CONTENT_DIR', dirname( __FILE__ ) . '/content' );

/** Sets up WordPress vars and included files. */
require_once( ABSPATH . 'wp-settings.php' );
```
