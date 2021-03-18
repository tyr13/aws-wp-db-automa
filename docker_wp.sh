#!/bin/bash

#Installing Docker
sudo apt-get update
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt-get install -y docker-compose

#Creating wp-config.php file
cat <<'EOF' >>~/key/wp-config.php
<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** MySQL database username */
define( 'DB_USER', 'wordpress' );

/** MySQL database password */
define( 'DB_PASSWORD', 'wordpress' );

/** MySQL hostname */
define( 'DB_HOST', '10.0.0.*:3306' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'C~`s,An%3u7h,4YpAv3+!@K5=K*e[L3I9!Ti?S4^Bgx Wy?.%0^1:ECW:TSk(Qf=' );
define( 'SECURE_AUTH_KEY',  'E&@S:i*/*iQL*.^rVwSJT/WO9rlp/juB9ZNpi`L gSl-2^T5E7m8b/zB:FS#gm(q' );
define( 'LOGGED_IN_KEY',    'A_oO]v0b*8iWH8]o<+PeL~ rv+I}MS# MsqT5BkZ(aC5g42-$;u@s kR1/8%C$eJ' );
define( 'NONCE_KEY',        'E#>G8Dmxyr*ufk%dH/p8XxuPx:f|u;bxuZ=[Qn.8c*qk|aeL204e{MqQG<M)-KF~' );
define( 'AUTH_SALT',        'gc~Vlb0_2319wD0-nhyNXezD;3 N8[/R&&Msz8,I,1~|39VB>OhhoUvc!V_O#_K@' );
define( 'SECURE_AUTH_SALT', 'F }+N9>x({|A&/5N*N~/K#M+}HGBrgww}/?,xp!w+q$c!cj~hX>|sC8Y-(jO&z5:' );
define( 'LOGGED_IN_SALT',   'fr?V|QE)^H[9hE?w^:wFUrsYV[W)%Eehd0W#]2S&HdE^@xkAF6f<P@c;oXD~2O0.' );
define( 'NONCE_SALT',       ' Ee(fGFg=:i4OG>;CN!|guePu>2qZ$pF?:.wcHV{+[D4 22v^@HKcmG>&C,mP3`s' );

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
EOF

cd ~/key

#Setup Wordpress container. You will need to configure Worpdress manually. COPY command is commented out. If you want to use predefined config file please do not forget to modify the wp-config.php file above.
echo "
FROM wordpress:5.6
VOLUME "/var/www/html"
EXPOSE 80 80 
" > Dockerfile
#COPY wp-config.php /var/www/html

sudo docker build . > ~/key/build

#Run Wordpress container
sudo docker run -p 80:80 -d $(cat build | grep Successfully | cut -d " " -f 3)