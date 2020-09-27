#!/bin/bash
###############

echo ""
echo "Welcome to the Runcloud Bedrock deployment script."
echo 'This will create and install Bedrock on a New Web App.'
echo ""

# Pre Fill Variables
serverid=XXXX <-- Server ID found in the URL
appname=example <-- Whatever friendly name you want to call your app
domain=example.com <-- Your domain name
user=XXXX <-- Runcloud user ID (Default user is "runcloud" but you want the actual user ID number)
serverip=XXX.XXX.XX.XXX <-- Enter Server IP Address
token= XXXX <-- Runcloud API key
wpusername= admin <-- WP Username
wpuserpass= password <-- WP User Password

# Check Variables Are Set

echo "Start Checking Variables Are Set..."
echo ""
echo ""
echo "Checking server ID is set..."
	if [[ -z "$serverid" ]]; then
		echo "Must provide Server ID in environment" 1>&2
		exit 1
	fi

sleep 1

echo "Checking App Name is set..."

sleep 1

	if [[ -z "$appname" ]]; then
		echo "Must provide App Name in environment" 1>&2
		exit 1
	fi
	
sleep 1

echo "Checking Domain Name is set..."

sleep 1

	if [[ -z "$domain" ]]; then
		echo "Must provide Domain Name in environment" 1>&2
		exit 1
	fi
	
sleep 1

	echo "Checking Runcloud API is set..."

sleep 1

	if [[ -z "$user" ]]; then
		echo "Must provide Runcloud User ID in environment" 1>&2
		exit 1
	fi
	
sleep 1

	if [[ -z "$token" ]]; then
		echo "Must provide API Token in environment" 1>&2
		exit 1
	fi
	
sleep 1

	if [[ -z "$serverip" ]]; then
		echo "Must provide Server IP in environment" 1>&2
		exit 1
	fi
	
sleep 1
echo "Check Complete..."

sleep 1

echo ""
echo "Generating Random Credentials."
echo ""

# Generate Random Credentials
genBaseName=$(openssl rand -hex 16 | rev | cut -c11- | rev)
echo "Database name generated..."
genBaseUser=$(openssl rand -hex 16 | rev | cut -c11- | rev)
echo "Database username generated..."
genBaseUserPass=$(openssl rand -hex 16 | rev | cut -c11- | rev)
echo "Database password generated..."
dbname=$genBaseName
dbuser=$genBaseUser
dbuserpw=$genBaseUserPass

sleep 3

echo ""
echo "Create a new web application in runcloud."
echo 'This will create and setup a new web application.'
echo ""

sleep 1

echo Creating Web Application...

curl --request POST \
	--url https://manage.runcloud.io/api/v2/servers/$serverid/webapps/custom \
	--header 'accept: application/json' \
	--header 'authorization: Basic '$token'' \
	--header 'content-type: application/json' \
	--data '{
	"name": "'$appname'",
	"domainName": "'$domain'",
	"user": "'$user'",
	"publicPath": "",
	"phpVersion": "php73rc",
	"stack": "nativenginx",
	"stackMode": "production",
	"clickjackingProtection": true,
	"xssProtection": true,
	"mimeSniffingProtection": true,
	"processManager": "ondemand",
	"processManagerMaxChildren": 50,
	"processManagerMaxRequests": 500,
	"openBasedir": "/home/runcloud/webapps/'$appname':/var/lib/php/session:/tmp",
	"timezone": "UTC",
	"disableFunctions": "getmyuid,passthru,leak,listen,diskfreespace,tmpfile,link,ignore_user_abort,shell_exec,dl,set_time_limit,exec,system,highlight_file,source,show_source,fpassthru,virtual,posix_ctermid,posix_getcwd,posix_getegid,posix_geteuid,posix_getgid,posix_getgrgid,posix_getgrnam,posix_getgroups,posix_getlogin,posix_getpgid,posix_getpgrp,posix_getpid,posix,_getppid,posix_getpwuid,posix_getrlimit,posix_getsid,posix_getuid,posix_isatty,posix_kill,posix_mkfifo,posix_setegid,posix_seteuid,posix_setgid,posix_setpgid,posix_setsid,posix_setuid,posix_times,posix_ttyname,posix_uname,proc_open,proc_close,proc_nice,proc_terminate,escapeshellcmd,ini_alter,popen,pcntl_exec,socket_accept,socket_bind,socket_clear_error,socket_close,socket_connect,symlink,posix_geteuid,ini_alter,socket_listen,socket_create_listen,socket_read,socket_create_pair,stream_socket_server",
	"maxExecutionTime": 30,
	"maxInputTime": 60,
	"maxInputVars": 1000,
	"memoryLimit": 256,
	"postMaxSize": 256,
	"uploadMaxFilesize": 256,
	"sessionGcMaxlifetime": 1440,
	"allowUrlFopen": true
}'

sleep 1
echo ""
echo "Web Application Complete..."
echo ""

sleep 3

echo ""
echo "Create a new database & user."
echo 'This will create and setup a new database and grant user .'
echo ""

# Create Database
echo ""
echo ""
sleep 3
echo Creating Database...


curl --request POST \
	--url https://manage.runcloud.io/api/v2/servers/$serverid/databases \
	--header 'accept: application/json' \
	--header 'authorization: Basic '$token'' \
	--header 'content-type: application/json' \
	--data '{
		"name": "'$dbname'"
}'

# Create db user
echo ""
echo ""
sleep 5
echo Creating Database User...


curl --request POST \
	--url https://manage.runcloud.io/api/v2/servers/$serverid/databaseusers \
	--header 'accept: application/json' \
	--header 'authorization: Basic '$token'' \
	--header 'content-type: application/json' \
	--data '{
		"username": "'$dbuser'",
		"password": "'$dbuserpw'"
}'

# Get Database ID
echo ""
echo ""
sleep 5
echo Getting Database ID...

db_id="$(curl --request GET \
		--url https://manage.runcloud.io/api/v2/servers/$serverid/databases \
		--header 'accept: application/json' \
		--header 'authorization: Basic '$token'' \
		--header 'content-type: application/json' \
		| jq '.data[] | select(.[]=="'$dbname'")' | grep '"id":' | grep -Eo '[0-9]{1,100}')"

sleep 5
echo ""
echo ""
echo Got Database ID...
echo $db_id;


# get database user id
echo ""
echo ""
sleep 5
echo Getting Database User ID...
	
dbuserid="$(curl --request GET \
	--url https://manage.runcloud.io/api/v2/servers/$serverid/databaseusers \
	--header 'accept: application/json' \
	--header 'authorization: Basic '$token'' \
	--header 'content-type: application/json' \
	| jq '.data[] | select(.[]=="'$dbuser'")' | grep '"id":' | grep -Eo '[0-9]{1,100}')"

sleep 5
echo ""
echo ""
echo Got user ID...
echo $dbuserid;

# attach db user
echo ""
echo ""
sleep 5
echo Granting Database User To Database...

curl --request POST \
	--url https://manage.runcloud.io/api/v2/servers/$serverid/databases/$db_id/grant \
	--header 'authorization: Basic '$token'' \
	--header 'accept: application/json' \
	--header 'content-type: application/json' \
	--data '{
	"id": "'$dbuserid'"
}'

sleep 1
echo ""
echo "Database Setup Complete..."
echo ""


# SSH connection & Install Bedrock
echo ""
echo "Connect to server and install Bedrock."
echo 'This will create and setup the WordPress Site .'
echo ""
sleep 5
echo ""
echo Trying to Logging In ...
echo ""

ssh runcloud@"$serverip" << EOF
echo "Now Logged In"
echo ""

cd webapps/$appname
rm index.html

echo "Start Installing Bedrock"
echo ""

sleep 3

composer create-project roots/bedrock

sleep 1

echo "bedrock has installed"

sleep 10

echo "changing directory"
sleep 3

cd bedrock

echo "trying to set .env"

wp package install aaemnnosttv/wp-cli-dotenv-command:^2.0
wp dotenv salts regenerate
wp dotenv set DB_NAME $dbname --quote-single
wp dotenv set DB_USER $dbuser --quote-single
wp dotenv set DB_PASSWORD $dbuserpw --quote-single
wp dotenv set WP_ENV production --quote-single
wp dotenv set WP_HOME https://$domain --quote-single

sleep 3
echo "Setting Up WordPress..."
echo ""
sleep 1

# Install wordpress via wp-cli
wp core install --url=$domain --title=$domain --admin_name=$wpusername --admin_password=$wpuserpass --admin_email=admin@$domain --path=web/wp

# Setup dependencies
# composer require wpackagist-plugin/wp-mailhog-smtp


# Plugin Activate
# wp plugin activate wp-mailhog-smtp --path=wp

sleep 3
echo "Logging out of SSH"
exit
sleep 2
EOF

echo ""
echo "Now Logged Out."
sleep 1
echo ""
echo "Now need to set the public path for Bedrock Directory  ."
echo ""
sleep 5
echo ""
echo "Trying to get the application ID..."
echo ""
sleep 1

# Get Web App ID To Update Path
echo "getting id for bedrock...."
echo ""
	webappid="$(curl --request GET \
		--url https://manage.runcloud.io/api/v2/servers/$serverid/webapps \
		--header 'accept: application/json' \
		--header 'authorization: Basic '$token'' \
		--header 'content-type: application/json' \
		| jq '.data[] | select(.[]=="'$appname'")' | grep '"id":' | grep -Eo '[0-9]{1,100}')"
		
		sleep 5
		
echo "Got Web App ID..."
echo "$webappid"
echo ""

sleep 3

echo "Updating the path in runcloud settings..."
sleep 1

		curl --request PATCH \
			--url https://manage.runcloud.io/api/v2/servers/$serverid/webapps/$webappid/settings/fpmnginx \
			--header 'accept: application/json' \
			--header 'authorization: Basic '$token'' \
			--header 'content-type: application/json' \
			--data '{
			"name": "'$appname'",
			"domainSelection": "customDomain",
			"customName": "",
			"domainName": "'$domain'",
			"useExistingUser": true,
			"user": "'$user'",
			"newUser": null,
			"publicPath": "\/bedrock\/web",
			"phpVersion": "php74rc",
			"stack": "nativenginx",
			"stackMode": "production",
			"advanceSetting": false,
			"clickjackingProtection": true,
			"xssProtection": true,
			"mimeSniffingProtection": true,
			"proxyProtocol": false,
			"processManager": "ondemand",
			"processManagerStartServers": 20,
			"processManagerMinSpareServers": 10,
			"processManagerMaxSpareServers": 30,
			"processManagerMaxChildren": 50,
			"processManagerMaxRequests": 500,
			"openBasedir": "/home/runcloud/webapps/'$appname':/var/lib/php/session:/tmp",
			"timezone": "UTC",
			"disableFunctions": "getmyuid,passthru,leak,listen,diskfreespace,tmpfile,link,ignore_user_abort,shell_exec,dl,set_time_limit,exec,system,highlight_file,source,show_source,fpassthru,virtual,posix_ctermid,posix_getcwd,posix_getegid,posix_geteuid,posix_getgid,posix_getgrgid,posix_getgrnam,posix_getgroups,posix_getlogin,posix_getpgid,posix_getpgrp,posix_getpid,posix,_getppid,posix_getpwuid,posix_getrlimit,posix_getsid,posix_getuid,posix_isatty,posix_kill,posix_mkfifo,posix_setegid,posix_seteuid,posix_setgid,posix_setpgid,posix_setsid,posix_setuid,posix_times,posix_ttyname,posix_uname,proc_open,proc_close,proc_nice,proc_terminate,escapeshellcmd,ini_alter,popen,pcntl_exec,socket_accept,socket_bind,socket_clear_error,socket_close,socket_connect,symlink,posix_geteuid,ini_alter,socket_listen,socket_create_listen,socket_read,socket_create_pair,stream_socket_server",
			"maxExecutionTime": 30,
			"maxInputTime": 60,
			"maxInputVars": 1000,
			"memoryLimit": 256,
			"postMaxSize": 256,
			"uploadMaxFilesize": 256,
			"sessionGcMaxlifetime": 1440,
			"allowUrlFopen": true,
			"dnsProviderSelection": null,
			"cancelToken": null
		}'
		
sleep 3

echo "Path Updated..."

sleep 1	


echo "Trying to sign SSL..."

sleep 3


curl --request POST \
	--url https://manage.runcloud.io/api/v2/servers/$serverid/webapps/$webappid/ssl \
	--header 'accept: application/json' \
	--header 'authorization: Basic '$token'' \
	--header 'content-type: application/json' \
	--data '{
	"provider": "letsencrypt",
	"enableHttp": true,
	"enableHsts": false,
	"http2": true,
	"brotli": true,
	"privateKey": "",
	"certificate": "",
	"authorizationMethod": "http-01",
	"externalApi": null,
	"environment": "live",
	"ssl_protocol_id": 2,
	"cancelToken": null
}'

sleep 5
		
# Provide user information on install
echo "WordPress has been downloaded and config file has been generated, site is installed."
echo "Login At: https://$domain"
echo "Username: $wpusername"
echo "Password: $wpuserpass"
