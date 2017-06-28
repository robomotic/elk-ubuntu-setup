#!/bin/bash


sudo apt-get install software-properties-common python-software-properties

sudo apt-get update


# --------------------------- Install JAVA 8 ---------------------------

read -p "Press [Enter] key to install Java 8..."

# Add the Oracle Java PPA to apt
sudo add-apt-repository ppa:webupd8team/java

# Update your apt package database:
sudo apt-get update

# Install the latest stable version of Oracle Java 7 (and accept the license agreement that pops up):
sudo apt-get install oracle-java8-installer

# append this in last line
sudo nano JAVA_HOME='/usr/lib/jvm/java-8-oracle/jre/bin/java'
source /etc/environment
echo $JAVA_HOME

# allow Java to access privileged ports
setcap cap_net_bind_service=+epi /usr/lib/jvm/java-7-oracle/jre/bin/java
# --------------------------- Install Elasticsearch ---------------------------

read -p "Press [Enter] key to install Elasticseach..."

# Run the following command to import the Elasticsearch public GPG key into apt:
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

sudo apt-get install apt-transport-https

# Create the Elasticsearch source list:
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list

# Update your apt package database:
sudo apt-get update

# Install Elasticsearch with this command:
export ES_SKIP_SET_KERNEL_PARAMETERS=true && apt-get install elasticsearch

echo " "
echo "------------ Configure Elasticsearch ------------"
echo "Add the following line somewhere in the file, to disable dynamic scripts:"
echo "         script.disable_dynamic: true"
echo " "
echo "You may also want to restrict outside access to your Elasticsearch instance (port 9200),"
echo "so outsiders can't read your data or shutdown your Elasticseach cluster through the HTTP API."
echo "Find the line that specifies network.host and uncomment it so it looks like this:"
echo "         network.host: localhost"
echo " "
read -p "Press [Enter] key to configure Elasticseach..."

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service

echo "Start "
echo "sudo systemctl start elasticsearch.service "
echo "Stop "
echo "sudo systemctl stop elasticsearch.service"

# Elasticsearch is now installed. Let's edit the configuration:
sudo nano /etc/elasticsearch/elasticsearch.yml

# Now start Elasticsearch:
sudo systemctl restart elasticsearch.service

read -p "Press [Enter] key to install Kibana..."

# -------------------------- Install Kibana --------------------------

# Download Kibana to your home directory with the following command:
sudo apt-get install kibana

#sudo /bin/systemctl daemon-reload
#sudo /bin/systemctl enable kibana.service

sudo /etc/kibana/kibana.yml

echo " "
echo "------ Configure Kibana ------"
echo "In the Kibana configuration file, find the line that specifies the elasticsearch,"
echo "and replace the port number (9200 by default) with 80"
echo "        elasticsearch: http://+window.location.hostname+:80"
echo " "    
read -p "Press [Enter] key to configure Kibana..."

# Open the Kibana configuration file for editing:
sudo nano ~/kibana-3.1.2/config.js

# We will be using Nginx to serve our Kibana installation, so let's move the files into an appropriate location.
# Create a directory with the following command:
sudo mkdir -p /var/www/kibana3

# Now copy the Kibana files into your newly-created directory:
sudo cp -R ~/kibana-3.1.2/* /var/www/kibana3/

# -------------------------- Install Nginx --------------------------

read -p "Press [Enter] key to Install Nginx..."

sudo apt-get install nginx

# Download the sample Nginx configuration from Kibana's github repository to your home directory:
cd ~; wget https://gist.githubusercontent.com/thisismitch/2205786838a6a5d61f55/raw/f91e06198a7c455925f6e3099e3ea7c186d0b263/nginx.conf

echo " "
echo "------------- Configure Nginx -------------"
echo "Find and change the values of the server_name to your FQDN (or localhost if you aren't using a domain name)"
echo "and root to where we installed Kibana, so they look like the following entries:"
echo "     server_name FQDN;"
echo "     root /var/www/kibana3;"
echo " "
read -p "Press [Enter] key to configure nginx.conf..."


# Check this https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elk-stack-on-ubuntu-16-04

# Now copy it over your Nginx default server block with the following command:
sudo cp nginx.conf /etc/nginx/sites-available/default

# Now we will install apache2-utils so we can use htpasswd to generate a username and password pair:
sudo apt-get install apache2-utils

# Then generate a login that will be used in Kibana to save and share dashboards (substitute your own username):
read -p "Enter username to generate a login that will be used in Kibana to save and share dashboards:" username
# sudo htpasswd -c /etc/nginx/conf.d/kibana.myhost.org.htpasswd $username
echo "kibanaadmin:`openssl passwd -apr1`" | sudo tee -a /etc/nginx/htpasswd.users

# Then enter a password and verify it. The htpasswd file just created is referenced in the Nginx
# configuration that you recently configured.

# Open the sample configuration file for editing:
sudo nano nginx.conf

sudo nginx -t

# Now restart Nginx to put our changes into effect:
sudo systemctl restart nginx

# -------------------------- Install Logstash --------------------------

read -p "Press [Enter] key to install logstash..."

# The Logstash package is available from the same repository as Elasticsearch, and we already installed that public key,
# so let's create the Logstash source list:
echo 'deb http://packages.elasticsearch.org/logstash/1.4/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash.list

# Update your apt package database:
sudo apt-get update

# Install Logstash with this command:
sudo apt-get install logstash=1.4.2-1-2c0f5a1

read -p "Press [Enter] to generate SSL Certificates for Lumberjack..."

sudo mkdir -p /etc/pki/tls/certs
sudo mkdir /etc/pki/tls/private

cd /etc/pki/tls; sudo openssl req -x509 -batch -nodes -days 3650 -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt

# -------------------------- Configure Logstash --------------------------

echo " "
echo "------------- Configure Logstash -------------"
echo "Edit/create/copy conf.d files and any supporting files."
echo "These are saved in the /etc/logstash/ directory."
echo " "
echo " NOTES:"
echo "** logstash-contrib NOT installed."
echo "** Please do it manually if needed."
echo "** (Need to add to this script)"
echo " "
echo "*** To prevent logstash-web from starting automatically,"
echo "*** edit /etc/init/logstash-web.conf and set"
echo '*** "start on virtual-filesystems" to “start on never”.'
echo " "
echo " ---> End of script <--"
echo " "
