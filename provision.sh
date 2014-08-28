#!/bin/bash
echo "Provisioning..."

# default variables
HOST="wp.local"
WP_VERSION="latest"

if [ "$WP_VERSION" == "latest" ];then
    WP_INSTALL_DIR="/var/www/html/wordpress"
    WP_INSTALL_FILE="latest.tar.gz"
    WP_SERVER_NAME=$HOST
    WP_DATABASE_NAME="wordpress"
    APACHE_SITE_CONFIG_FILE="/etc/apache2/sites-available/000-default.conf"
else
    WP_INSTALL_DIR="/var/www/html/wordpress-${WP_VERSION}"
    WP_INSTALL_FILE="wordpress-${WP_VERSION}.tar.gz"
    WP_SERVER_NAME="${WP_VERSION//./}.$HOST"
    WP_DATABASE_NAME="wordpress_${WP_VERSION//./}"
    APACHE_SITE_CONFIG_FILE="/etc/apache2/sites-available/${WP_SERVER_NAME}.conf"
fi

# Debug information
echo "-------------------------------------"
echo "Installation directory: $WP_INSTALL_DIR"
echo "Server name: $WP_SERVER_NAME"
echo "Database name: $WP_DATABASE_NAME"
echo "-------------------------------------"

# Download and unzip the wordpress
if [ ! -d $WP_INSTALL_DIR ];then

    if [ ! -f "/tmp/$WP_INSTALL_FILE" ];then
        if [ "$WP_VERSION" == "" ];then
            echo "Downloading latest wordpress..."
        else
            echo "Downloading wordpress ${WP_VERSION} ..."
        fi

        wget "http://wordpress.org/$WP_INSTALL_FILE" -O "/tmp/$WP_INSTALL_FILE"

        if [ ! -f "/tmp/$WP_INSTALL_FILE" ];then
            echo "Failed to download wordpress zip file"
            exit 1
        fi

        echo "Wordpress downloaded."
    fi

    if [ -d /tmp/wordpress ];then
        sudo rm -fR /tmp/wordpress
    fi

    tar -C /tmp -zxvf "/tmp/$WP_INSTALL_FILE" 
    mv "/tmp/wordpress" $WP_INSTALL_DIR

    echo "Wordpress installed."
    echo ""
fi

# Create wordpress database
echo "Creating wordpress database..."
mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS ${WP_DATABASE_NAME}"
echo "Wordpress database created."
echo ""

# Change file permission
echo "Change directory permissions..."
sudo chmod -R 777 "$WP_INSTALL_DIR/wp-content"
echo "wp-content permissions changed."
echo ""

# Add wp-config.php
if [ ! -f "$WP_INSTALL_DIR/wp-config.php" ]; then
    echo "Creating wp-config.php..."
    cp "$WP_INSTALL_DIR/wp-config-sample.php" "$WP_INSTALL_DIR/wp-config.php"

    # replace database settings
    sed -i.bak "s/'database_name_here'/'${WP_DATABASE_NAME}'/g" "$WP_INSTALL_DIR/wp-config.php"
    sed -i.bak "s/'username_here'/'root'/g" "$WP_INSTALL_DIR/wp-config.php"
    sed -i.bak "s/'password_here'/'root'/g" "$WP_INSTALL_DIR/wp-config.php"

    echo "wp-config.php created."
    echo ""
fi

# copy apache site configuration
if [ ! -f $APACHE_SITE_CONFIG_FILE ];then
    sudo cp /etc/apache2/sites-available/000-default.conf $APACHE_SITE_CONFIG_FILE
fi

# Replace server name
echo "Replace ServerName..."
sudo sed -i.bak "s/#\?ServerName .*/ServerName ${WP_SERVER_NAME}/g" $APACHE_SITE_CONFIG_FILE
sudo sed -i.bak "s,DocumentRoot .*,DocumentRoot ${WP_INSTALL_DIR},g" $APACHE_SITE_CONFIG_FILE
echo "ServerName replaced."
echo ""

# Restart apache
echo "Restarting apache..."
if [ "$WP_VERSION" != "latest" ];then
    sudo a2ensite $WP_SERVER_NAME
fi
sudo service apache2 restart
echo "apache restarted."
echo ""

echo "${WP_SERVER_NAME} Provisioned!"
