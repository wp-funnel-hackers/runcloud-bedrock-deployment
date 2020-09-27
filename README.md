# Deploy WordPress with Bedrock using Runcloud API

A less than perfect and simple bash script to deploy WordPress with Bedrock using the Runcloud API.

This assumes you already have a SSH key pair setup and on the machine you're running it from.

1. Fill in the variables IP, Username, API token, etc.
2. Run the script

Then it will perform the following.

- Generate a random 22 character Database Name, Database User and Database Password.
- Creates a new PHP web application using thier Nativenginx Stack
- Create a new Database
- Create Database User
- Fetch the Database user ID and grant/assign the user to the database.
- Connect to the server via SSH
- Install Bedrock by roots.io
- Sets the .env using dotenv
  - Generates Salt
  - Set DB Name, User, Password
  - Set WP_ENV
  - Set WP_HOME
 - Install WP Core via wp-cli to setup the site
  - URL
  - Title
  - Username for login
  - User password
  - Admin Email
 - Install plugins via composer
 - Activate plugins
 - Updates the public path for the Bedrock install `/bedrock/web'
 - Setup SSL with Lets Ecrypt


