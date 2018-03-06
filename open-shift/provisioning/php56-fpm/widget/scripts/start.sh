#!/bin/bash

#TODO Add variables to this after it is working correctly.

PHP_FPM_WWW_CONFIG=/usr/local/etc/php-fpm.d/www.conf
PHP_FPM_CONFIG=/usr/local/etc/php-fpm.conf

#sed -i "s@listen = /var/run/php5-fpm.sock@listen = 9000@" ${PHP_FPM_WWW_CONFIG}

sed -i "s@;pm.status_path = /status@pm.status_path = /fpm/status@" ${PHP_FPM_WWW_CONFIG}
sed -i "s@;ping.path = /ping@ping.path = /ping@" ${PHP_FPM_WWW_CONFIG}
sed -i 's@;error_log = log/php-fpm.log@error_log = log/error.log@' ${PHP_FPM_WWW_CONFIG}
sed -i 's@;access.log = log/\$pool.access.log@access.log = var/log/\$pool.access.log@' ${PHP_FPM_WWW_CONFIG}
sed -i 's@;access.format@access.format@' ${PHP_FPM_WWW_CONFIG}
#sed -i "s@;request_slowlog_timeout = 0@request_slowlog_timeout = 5s@" ${PHP_FPM_WWW_CONFIG}
#sed -i "s@;slowlog = log/\$pool.log.slow@slowlog = var/log/\$pool.log.slow@" ${PHP_FPM_WWW_CONFIG}

# unset, handled by image config
sed -i "s@listen = 127.0.0.1:9000@;listen = 127.0.0.1:9000@" ${PHP_FPM_WWW_CONFIG}



echo "env[APP_SERVER_NAME] = ${APP_SERVER_NAME:-com.singlehop.dev.widget}" >> ${PHP_FPM_WWW_CONFIG}
# Try new error log
sed -i 's@;php_admin_value[error_log] = /var/log/fpm-php.www.log@php_admin_value[error_log] = log/fpm-php.www.log@' ${PHP_FPM_WWW_CONFIG}
sed -i 's@;php_admin_flag[log_errors] = on@php_admin_flag[log_errors] = on@' ${PHP_FPM_WWW_CONFIG}

#echo "emergency_restart_threshold = 10" >> ${PHP_FPM_CONFIG};
#echo "emergency_restart_interval = 1m" >> ${PHP_FPM_CONFIG};
#echo "process_control_timeout = 10s" >> ${PHP_FPM_CONFIG};

exec /usr/local/sbin/php-fpm --nodaemonize

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
