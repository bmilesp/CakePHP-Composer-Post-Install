#!/bin/bash

PROJECT_NAME=$1
DB_DEFAULT_USER=$2
DB_DEFAULT_PASSWORD=$3

ROOT_DIR='Plugin/CakephpPostInstall/Console'

yes y | Vendor/bin/cake bake project .

#add tmp folders
mkdir tmp
mkdir cache
mkdir cache/models
mkdir cache/persistent
mkdir cache/views
mkdir logs
mkdir sessions
mkdir tests
touch tests/empty
touch sessions empty
touch logs/empty
touch cache/models/empty
touch cache/persistent/empty
touch cache/views/empty


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

OLD="database_name"
sed -i "s/$OLD/$PROJECT_NAME/g" Config/database.php

mysql -uroot -e "create database if not exists $PROJECT_NAME"


cat $ROOT_DIR/autoloader_fix.inc >> Config/bootstrap.php

OLD="define('CAKE_CORE_INCLUDE_PATH"
NEW="define('CAKE_CORE_INCLUDE_PATH',ROOT . DS . APP_DIR . DS . 'Vendor' . DS . 'cakephp' . DS . 'cakephp' . DS . 'lib');"
sed -i "/$OLD/c\ $NEW" webroot/index.php
sed -i "/$OLD/c\ $NEW" webroot/test.php
