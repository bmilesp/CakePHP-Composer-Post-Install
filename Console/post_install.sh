#!/bin/bash
# post_install.sh -d saas -s root -u password -g localhost

P_NAME=saas
DB_USER=root
DB_PASSWORD=''
DB_HOST=localhost
ROOT_PATH = /var/www/html/saas


while getopts "d:s:u:g:p:" OPTION; do
    case $OPTION in
        d)
            P_NAME=$OPTARG
            ;;
        s)
            DB_USER=$OPTARG
            ;;
        u)
            DB_PASSWORD=$OPTARG
            ;;
        g)
            DB_HOST=$OPTARG
            ;;
        p)
             ROOT_PATH=$OPTARG
            ;;
    esac
done

export P_NAME
export DB_USER
export DB_PASSWORD
export DB_HOST
export ROOT_PATH

echo $P_NAME
echo $DB_USER
echo $DB_PASSWORD
echo $DB_HOST


ROOT_DIR='Plugin/CakephpPostInstall/Console'

yes y | Vendor/bin/cake bake project .

touch tmp/cache/models/empty
touch tmp/cache/persistent/empty
touch tmp/cache/views/empty
touch tmp/logs/empty
touch tmp/sessions/empty
touch tmp/tests/empty

#. $ROOT_DIR/bootstrap.sh
cp Config/database.php.default Config/database.php

#maybe get single file from cakephp github repo instead?
cp $ROOT_DIR/.gitignore .
cp $ROOT_DIR/.gitattributes .
OLD="user"
sed -i "s/$OLD/$DB_USER/g" Config/database.php

OLD="=> 'password'"
NEW="=> '$DB_PASSWORD'"
sed -i "s/$OLD/$NEW/g" Config/database.php

OLD="=> 'localhost'"
NEW="=> '$DB_HOST'"
sed -i "s/$OLD/$NEW/g" Config/database.php

OLD="database_name"
sed -i "s/$OLD/$P_NAME/g" Config/database.php

#modify appController for SaasOverrides (yes there is a cclass SIC in there on purpose)
sed -i "/App::uses('Controller', 'Controller');/a App::uses('SaasOverridesController', 'SaasOverrides.Controller');" Controller/AppController.php
sed -i "/class AppController extends Controller/ cclass AppController extends SaasOverridesController {" Controller/AppController.php

#parse extensions
sed -i "/CakePlugin::routes();/a\Router::parseExtensions('json','csv');" Config/routes.php

#### need to change here
mysql -h$DB_HOST -u$DB_USER -p$DB_PASSWORD -e "create database if not exists $P_NAME"


cat $ROOT_DIR/autoloader_fix.inc >> Config/bootstrap.php
cat $ROOT_DIR/add_plugins.inc >> Config/bootstrap.php

OLD="define('CAKE_CORE_INCLUDE_PATH"
NEW="define('CAKE_CORE_INCLUDE_PATH',ROOT . DS . APP_DIR . DS . 'Vendor' . DS . 'cakephp' . DS . 'cakephp' . DS . 'lib');"
sed -i "/$OLD/c\ $NEW" webroot/index.php
sed -i "/$OLD/c\ $NEW" webroot/test.php
