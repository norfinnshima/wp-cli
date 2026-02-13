開発の流れ
===

## ◯ Download core

* ```--path=wp```をつけると、wpフォルダを作成してその中にダウンロードする 
```
wp core download --path=wp --locale=ja
```

### ▼エラー: PHP Fatal error:  Allowed memory size of 134217728 bytes exhausted

* 一時的にメモリ上限を増やして実行
```
php -d memory_limit=512M $(which wp) core download --path=wp --locale=ja
```


## ◯ Create wp-config

```
wp config create \
--dbname=testwp \
--dbuser=testwp \
--dbpass=testwp \
--dbhost=localhost:/Applications/MAMP/tmp/mysql/mysql.sock \
--dbprefix=testwpcli_ \
--path=wp
```

### ▼ MAMPを使用しない場合
```
wp config set DB_HOST localhost --path=wp
```

### DEBUG
```
wp config set WP_DEBUG true --raw --path=wp
```


## ◯ Install

```
wp core install \
--url=http://testwpcli.test:8888/wp \
--title="Test Site" \
--admin_user=testwp \
--admin_password=testwp \
--admin_email=test@example.com \
--path=wp
```

### ブラウザで確認
* http://testwpcli.test:8888/wp
* **管理画面:** /wp/wp-admin


## ◯ 管理画面の設定

### 言語
```
wp language core install ja --activate --path=wp
// wp language core activate ja --path=wp
```

### キャッチフレーズを空欄
```
wp option update blogdescription "" --path=wp
```

### タイムゾーン
```
wp option update timezone_string "Asia/Tokyo" --path=wp
```

### 日付形式
```
wp option update date_format "Y-m-d" --path=wp
```

### 検索エンジンをブロック
```
wp option update blog_public 0 --path=wp
```
* 0 = インデックス禁止
* 1 = 公開

### パーマリンク構造
```
wp rewrite structure '/%post_id%/' --path=wp
wp rewrite flush --path=wp
```
* flush は再生成。

### カラースキーム
```
wp user meta update admin admin_color ectoplasm --path=wp
```
※ 'admin' の部分はユーザー名


## ◯ プラグイン

```
wp plugin delete hello akismet --path=wp

wp plugin install \
wp-multibyte-patch \
classic-editor \
custom-post-type-ui \
advanced-custom-fields \
contact-form-7 \
--activate \
--path=wp

wp plugin update --all --path=wp
```


## ◯ テーマ

* アクティブ以外を削除
```
wp theme delete $(wp theme list --status=inactive --field=name --path=wp) --path=wp
```


## ◯ 固定ページ

### サンプルページ削除
```
wp post delete $(wp post list --post_type=page --name=sample-page --field=ID --path=wp) --force --path=wp
```

### 「会社概要」ページ作成
```
wp post create \
--post_type=page \
--post_title="会社概要" \
--post_name=about \
--post_status=publish \
--path=wp
```

### 「お問合せ」ページ作成
```
wp post create \
--post_type=page \
--post_title="お問合せ" \
--post_name=contact \
--post_status=publish \
--path=wp
```


## ◯ 投稿

### サンプル投稿
```
for i in {0..4}; do
  wp post create \
    --post_type=post \
    --post_status=publish \
    --post_title="サンプル投稿 $((i+1))" \
    --post_date="$(date -v+${i}M '+%Y-%m-%d %H:%M:%S')" \
    --path=wp
done
```


## ◯ ダッシュボード

```
wp user meta delete 1 metaboxhidden_dashboard --path=wp
wp eval '
update_user_meta(1, "metaboxhidden_dashboard", array(
  "dashboard_quick_press",
  "dashboard_primary",
  "dashboard_activity"
));
update_user_meta(1, "show_welcome_panel", 0);
' --path=wp
```


## ◯ コア、翻訳をアップデート
```
wp core update --path=wp
wp language core update --path=wp
wp language plugin update --all --path=wp
wp language theme update --all --path=wp
```
