Another WordPress container, which downloads and installs WordPress when the container is started.

When this container is started for the first time, it performs the following steps:

1. download and unpack WordPress
2. download and install WP-CLI
3. wait for the MySQL database to be ready
4. use WP-CLI to install the WordPress
5. install and activate the WordPress theme

When the container is subsequently started, these steps all detect that nothing
is required to be done.

## Usage

The WordPress configuration must be mounted into the container explicitly.  See
the directory structure (below).

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

The core WordPress directory is `/var/www/html/wordpress`.

The WordPress configuration should be mounted into the container at
`/var/www/html/wp-config.php`.
