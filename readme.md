### Installation

If you would like to automatically setup the database for the project,
Modify settings for mysql in Plugin/CakephpPostInstall/Console/bootstrap.sh

If you're not using install.sh (https://gist.github.com/bmilesp/933ab244e5d8a6550c84) You will have to chmod execute permissions on the following Files:

chmod 777 Plugin/CakephpPostInstall/Console/post_install.sh
chmod 777 Vendor/cakephp/cakephp/lib/Cake/Console/cake


Manually run: 
		bash Plugin/CakephpPostInstall/Console/post_install.sh

If you're running initially on a production server, probably should set
the permissions back (again, if not using install.sh (https://gist.github.com/bmilesp/933ab244e5d8a6550c84))

eg:

chmod 644 Plugin/CakephpPostInstall/Console/post_install.sh
chmod 644 Vendor/cakephp/cakephp/lib/Cake/Console/cake