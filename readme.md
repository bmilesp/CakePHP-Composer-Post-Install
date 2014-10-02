### Installation

If you would like to automatically setup the database for the project,
Modify settings for mysql in Plugin/CakephpPostInstall/Console/bootstrap.sh

You will have to chmod execute permissions on the following Files:

chmod 777 Plugin/CakephpPostInstall/Console/post_install.sh
chmod 777 Plugin/CakephpPostInstall/Console/bootstrap.sh
chmod 777 Vendor/cakephp/cakephp/lib/Cake/Console/cake

if you're running initially on a production server, probably should set
the permissions back

eg:

chmod 644 Plugin/CakephpPostInstall/Console/post_install.sh
chmod 644 Plugin/CakephpPostInstall/Console/bootstrap.sh
chmod 644 Vendor/cakephp/cakephp/lib/Cake/Console/cake