#!/bin/bash
# post_install.sh -d saas -s root -u password -g localhost

PROJECT_NAME=saas
DB_DEFAULT_USER=root
DB_DEFAULT_PASSWORD=''
DB_DEFAULT_HOST=localhost


while getopts "d:s:u:g:" OPTION; do
    case $OPTION in
        d)
            PROJECT_NAME=$OPTARG
            ;;
        s)
            DB_DEFAULT_USER=$OPTARG
            ;;
        u)
            DB_DEFAULT_PASSWORD=$OPTARG
            ;;
        g)
            DB_DEFAULT_HOST=$OPTARG
            ;;
    esac
done



ROOT_DIR='Plugin/CakephpPostInstall/Console'

yes y | Vendor/bin/cake bake project .

touch tmp/cache/models/empty
touch tmp/cache/persistent/empty
touch tmp/cache/views/empty
touch tmp/logs/empty
touch tmp/sessions/empty
touch tmp/tests/empty

. $ROOT_DIR/bootstrap.sh
cp Config/database.php.default Config/database.php

#maybe get single file from cakephp github repo instead?
cp $ROOT_DIR/.gitignore .
cp $ROOT_DIR/.gitattributes .
OLD="user"
sed -i "s/$OLD/$DB_DEFAULT_USER/g" Config/database.php

OLD="=> 'password'"
NEW="=> '$DB_DEFAULT_PASSWORD'"
sed -i "s/$OLD/$NEW/g" Config/database.php

OLD="=> 'localhost'"
NEW="=> '$DB_DEFAULT_HOST'"
sed -i "s/$OLD/$NEW/g" Config/database.php

OLD="database_name"
sed -i "s/$OLD/$PROJECT_NAME/g" Config/database.php

mysql -uroot -e "create database if not exists $PROJECT_NAME"


cat $ROOT_DIR/autoloader_fix.inc >> Config/bootstrap.php

OLD="define('CAKE_CORE_INCLUDE_PATH"
NEW="define('CAKE_CORE_INCLUDE_PATH',ROOT . DS . APP_DIR . DS . 'Vendor' . DS . 'cakephp' . DS . 'cakephp' . DS . 'lib');"
sed -i "/$OLD/c\ $NEW" webroot/index.php
sed -i "/$OLD/c\ $NEW" webroot/test.php
