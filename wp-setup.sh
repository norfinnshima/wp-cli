#!/bin/bash

set -e

### ===== Settings =====

WP_PATH="httpdocs/wp"
URL="http://testwpcli.test:8888/wp"

DB_NAME="testwp"
DB_USER="testwp"
DB_PASS="testwp"
DB_HOST="localhost:/Applications/MAMP/tmp/mysql/mysql.sock"
# DB_HOST="localhost"
DB_PREFIX="testwpcli_"

ADMIN_USER="testwp"
ADMIN_PASS="testwp"
ADMIN_EMAIL="test@example.com"

SITE_TITLE="Test Site"
BLOG_DESCRIPTION=""
TIMEZONE="Asia/Tokyo"
DATE_FORMAT="Y-m-d"

### 検索エンジンでの表示
# 0 = インデックス禁止, 1 = 公開
BLOG_PUBLIC=0

### パーマリンク構造
PERMALINK_STRUCTURE='/%post_id%/'

### プラグイン
PLUGINS=(
  wp-multibyte-patch
  classic-editor
  custom-post-type-ui
  advanced-custom-fields
  contact-form-7
)

### サンプル投稿数
SAMPLE_POSTS=5

### ====================


echo "=== Download core ==="
# wp core download --path=$WP_PATH --locale=ja
php -d memory_limit=512M $(which wp) core download --path=$WP_PATH --locale=ja


echo "=== Create config ==="
wp config create \
--dbname=$DB_NAME \
--dbuser=$DB_USER \
--dbpass=$DB_PASS \
--dbhost=$DB_HOST \
--dbprefix=$DB_PREFIX \
--path=$WP_PATH

wp config set WP_DEBUG true --raw --path=$WP_PATH


echo "=== Install ==="
wp core install \
--url=$URL \
--title="$SITE_TITLE" \
--admin_user=$ADMIN_USER \
--admin_password=$ADMIN_PASS \
--admin_email=$ADMIN_EMAIL \
--path=$WP_PATH


echo "=== Basic settings ==="
wp language core install ja --activate --path=$WP_PATH
wp option update blogdescription "$BLOG_DESCRIPTION" --path=$WP_PATH
wp option update timezone_string "$TIMEZONE" --path=$WP_PATH
wp option update date_format "$DATE_FORMAT" --path=$WP_PATH
wp option update blog_public $BLOG_PUBLIC --path=$WP_PATH

wp rewrite structure "$PERMALINK_STRUCTURE" --path=$WP_PATH
wp rewrite flush --path=$WP_PATH

ADMIN=$(wp user list --role=administrator --field=user_login --path=$WP_PATH)
wp user meta update $ADMIN admin_color ectoplasm --path=$WP_PATH


echo "=== Plugins ==="
wp plugin delete hello akismet --path=$WP_PATH

wp plugin install "${PLUGINS[@]}" --activate --path=$WP_PATH

wp plugin update --all --path=$WP_PATH


echo "=== Theme cleanup ==="
wp theme delete $(wp theme list --status=inactive --field=name --path=$WP_PATH) --path=$WP_PATH


echo "=== Pages ==="
wp post delete $(wp post list --post_type=page --name=sample-page --field=ID --path=$WP_PATH) --force --path=$WP_PATH

wp post create --post_type=page --post_title="会社概要" --post_name=about --post_status=publish --path=$WP_PATH
wp post create --post_type=page --post_title="お問合せ" --post_name=contact --post_status=publish --path=$WP_PATH


echo "=== Sample posts ==="
for ((i=0;i<$SAMPLE_POSTS;i++)); do
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
