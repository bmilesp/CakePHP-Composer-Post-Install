#!/bin/bash
# post_install.sh -d saas -s root -u password -g localhost -p /var/www/html/saas
P_NAME=saas
DB_USER=root
DB_PASSWORD=''
DB_HOST=localhost
ROOT_PATH='/var/www/html/saas'
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
echo $ROOT_PATH

echo "start"

yes y | $ROOT_PATH/Vendor/bin/cake bake project .

touch $ROOT_PATH/tmp/cache/models/empty
touch $ROOT_PATH/tmp/cache/persistent/empty
touch $ROOT_PATH/tmp/cache/views/empty
touch $ROOT_PATH/tmp/logs/empty
touch $ROOT_PATH/tmp/sessions/empty
touch $ROOT_PATH/tmp/tests/empty
sudo chmod 777 -R $ROOT_PATH/tmp

#. $ROOT_DIR/bootstrap.sh
cp $ROOT_PATH/Config/database.php.default $ROOT_PATH/Config/database.php

#maybe get single file from cakephp github repo instead?
cp "$ROOT_PATH/Plugin/CakephpPostInstall/Console/.gitignore" "$ROOT_PATH/.gitignore"
cp "$ROOT_PATH/Plugin/CakephpPostInstall/Console/.gitattributes" "$ROOT_PATH/.gitattributes"
OLD="user"
sed -i "s/$OLD/$DB_USER/g" $ROOT_PATH/Config/database.php

OLD="=> 'password'"
NEW="=> '$DB_PASSWORD'"
sed -i "s/$OLD/$NEW/g" $ROOT_PATH/Config/database.php

OLD="=> 'localhost'"
NEW="=> '$DB_HOST'"
sed -i "s/$OLD/$NEW/g" $ROOT_PATH/Config/database.php

OLD="database_name"
sed -i "s/$OLD/$P_NAME/g" $ROOT_PATH/Config/database.php

#modify appController for SaasOverrides (yes there is a cclass SIC in there on purpose)
sed -i "/App::uses('Controller', 'Controller');/a App::uses('SaasOverridesController', 'SaasOverrides.Controller');" $ROOT_PATH/Controller/AppController.php
sed -i "/class AppController extends Controller/ cclass AppController extends SaasOverridesController {" $ROOT_PATH/Controller/AppController.php

#parse extensions
sed -i "/CakePlugin::routes();/aouter::parseExtensions('json','csv');" $ROOT_PATH/Config/routes.php

#### need to change here
mysql -h$DB_HOST -u$DB_USER -p$DB_PASSWORD -e "create database if not exists $P_NAME"

ls -la $ROOT_PATH/Plugin/CakephpPostInstall/Console/
cat $ROOT_PATH/Plugin/CakephpPostInstall/Console/autoloader_fix.inc >> $ROOT_PATH/Config/bootstrap.php
cat $ROOT_PATH/Plugin/CakephpPostInstall/Console/add_plugins.inc >> $ROOT_PATH/Config/bootstrap.php

OLD="define('CAKE_CORE_INCLUDE_PATH"
NEW="define('CAKE_CORE_INCLUDE_PATH',ROOT . DS . APP_DIR . DS . 'Vendor' . DS . 'cakephp' . DS . 'cakephp' . DS . 'lib');"
sed -i "/$OLD/c\ $NEW" $ROOT_PATH/webroot/index.php
sed -i "/$OLD/c\ $NEW" $ROOT_PATH/webroot/test.php
