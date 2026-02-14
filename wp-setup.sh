#!/bin/bash

set -e

WP_PATH="httpdocs/wp"
URL="http://testwpcli.test:8888/wp"

echo "=== Download core ==="
# wp core download --path=$WP_PATH --locale=ja
php -d memory_limit=512M $(which wp) core download --path=$WP_PATH --locale=ja

echo "=== Create config ==="
wp config create \
--dbname=testwp \
--dbuser=testwp \
--dbpass=testwp \
--dbhost=localhost:/Applications/MAMP/tmp/mysql/mysql.sock \
--dbprefix=testwpcli_ \
--path=$WP_PATH

wp config set WP_DEBUG true --raw --path=$WP_PATH

echo "=== Install ==="
wp core install \
--url=$URL \
--title="Test Site" \
--admin_user=testwp \
--admin_password=testwp \
--admin_email=test@example.com \
--path=$WP_PATH

echo "=== Basic settings ==="
wp language core install ja --activate --path=$WP_PATH
wp option update blogdescription "" --path=$WP_PATH
wp option update timezone_string "Asia/Tokyo" --path=$WP_PATH
wp option update date_format "Y-m-d" --path=$WP_PATH
wp option update blog_public 0 --path=$WP_PATH

wp rewrite structure '/%post_id%/' --path=$WP_PATH
wp rewrite flush --path=$WP_PATH

ADMIN=$(wp user list --role=administrator --field=user_login --path=$WP_PATH)
wp user meta update $ADMIN admin_color ectoplasm --path=$WP_PATH

echo "=== Plugins ==="
wp plugin delete hello akismet --path=$WP_PATH

wp plugin install \
wp-multibyte-patch \
classic-editor \
custom-post-type-ui \
advanced-custom-fields \
contact-form-7 \
--activate \
--path=$WP_PATH

wp plugin update --all --path=$WP_PATH

echo "=== Theme cleanup ==="
wp theme delete $(wp theme list --status=inactive --field=name --path=$WP_PATH) --path=$WP_PATH

echo "=== Pages ==="
wp post delete $(wp post list --post_type=page --name=sample-page --field=ID --path=$WP_PATH) --force --path=$WP_PATH

wp post create --post_type=page --post_title="会社概要" --post_name=about --post_status=publish --path=$WP_PATH
wp post create --post_type=page --post_title="お問合せ" --post_name=contact --post_status=publish --path=$WP_PATH

echo "=== Sample posts ==="
for i in {0..4}; do
  wp post create \
    --post_type=post \
    --post_status=publish \
    --post_title="サンプル投稿 $((i+1))" \
    --post_date="$(date -v+${i}M '+%Y-%m-%d %H:%M:%S')" \
    --path=$WP_PATH
done

echo "=== Dashboard ==="
ID=$(wp user list --role=administrator --field=ID --path=$WP_PATH)

wp eval "
update_user_meta($ID, 'metaboxhidden_dashboard', array(
  'dashboard_quick_press',
  'dashboard_primary',
  'dashboard_activity'
));
update_user_meta($ID, 'show_welcome_panel', 0);
" --path=$WP_PATH

echo "=== Updates ==="
wp core update --path=$WP_PATH
wp language core update --path=$WP_PATH
wp language plugin update --all --path=$WP_PATH
wp language theme update --all --path=$WP_PATH

echo "✅ Setup complete"
