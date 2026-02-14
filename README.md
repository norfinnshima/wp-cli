wp-cli
===

## ◯ Handbook

* https://make.wordpress.org/cli/handbook/
* https://make.wordpress.org/cli/handbook/guides/verifying-downloads/


## ◯ CLI update

```
wp cli update
```


## ◯ For use MAMP-MySQL from WP-CLI

### @~/.zprofile
```
PHP_VERSION=$(ls /Applications/MAMP/bin/php/ | sort -n | tail -1)
export PATH=/Applications/MAMP/bin/php/${PHP_VERSION}/bin:$PATH
```
```
source ~/.zprofile
```

<!--
* XX.XX.XX -> MAMP-PHP version
```
export PATH=/Applications/MAMP/Library/bin:${PATH}
export WP_CLI_PHP=/Applications/MAMP/bin/php/phpXX.XX.XX/bin/php
source ~/.zprofile
```
-->

### Create wp-config
```
wp config create \
--dbname=testwp \
--dbuser=testwp \
--dbpass=testwp \
--dbhost=localhost:/Applications/MAMP/tmp/mysql/mysql.sock \
--dbprefix=testwpcli_ \
--path=wp
```


## ◯ wp-setup.sh

* ドキュメントルートとなるディレクトリと同じ場所に配置

### 実行権限を付ける
```
chmod +x wp-setup.sh
```

### 実行
```
./wp-setup.sh
```