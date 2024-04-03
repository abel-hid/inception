<?php
$env = parse_ini_file('/home/abel-hid/Desktop/inception/srcs/.env');

// echo "Domain Name: " . $env['DOMAIN_NAME'] . "\n";
// echo "MySQL Hostname: " . $env['MYSQL_HOSTNAME'] . "\n";
// echo "MySQL Database: " . $env['MYSQL_DATABASE'] . "\n";
// echo "MySQL User: " . $env['MYSQL_USER'] . "\n";
// echo "MySQL Password: " . $env['MYSQL_PASSWORD'] . "\n";
// echo "MySQL Root Password: " . $env['MYSQL_ROOT_PASSWORD'] . "\n";

define('DB_NAME', $env['MYSQL_DATABASE']);
define('DB_USER', $env['MYSQL_USER']);
define('DB_PASSWORD', $env['MYSQL_PASSWORD']);
define('DB_HOST', $env['MYSQL_HOSTNAME']);