#!/bin/bash
#
# OpenEMM Installation SCRIPT 
# Chimdi Azubuike 
# me@chimdi.com
# 
# Installation Guide
# http://downloads.sourceforge.net/project/openemm/OpenEMM%20documentation/Documentation%20%28latest%20versions%29/OpenEMM-2015_InstallAdminGuide_1.1.pdf?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fopenemm%2Ffiles%2FOpenEMM%2520documentation%2FDocumentation%2520%2528latest%2520versions%2529%2F&ts=1460318556&use_mirror=netix

# TODO: add option to select download location for the necessary dependencies (archives) in case the change


export MYSQL_ROOT_PASSWORD="redhat"
function create_user() {
groupadd openemm
useradd -m -g openemm -G adm -d /home/openemm -s /bin/bash -c "OpenEMM-2015" openemm
}
apt-get update -y
apt-get install -y python-software-properties -y
apt-get install -y software-properties-common python-software-properties -y
add-apt-repository ppa:git-core/ppa  -y

function install_prep() {
apt-get update -y
apt-get upgrade -y

# Create OpenEMM User
create_user

# Create OpenEMM Resource Directory
mkdir -p /opt/openemm

# Normalize Log File Naming for OpenEMM Sake
ln -s /var/log/mail.log /var/log/maillog
}

function install_java() {
echo "Installing Java 8"

add-apt-repository ppa:webupd8team/java -y
apt-get update -y
# Enable silent install
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

apt-get install oracle-java8-installer -y

update-alternatives --config java > /tmp/java_location.txt

# Symlyincing java to openemm root
ln -s /usr/lib/jvm/java-8-oracle/jre /opt/openemm/java
echo "export JAVA_HOME=/opt/openemm/java" > ~/.bashrc
source ~/.bashrc
}

apt-get install wget -y

cd /tmp
wget http://redrockdigimark.com/apachemirror/tomcat/tomcat-8/v8.5.15/bin/apache-tomcat-8.5.15.tar.gz
tar -zxf apache-tomcat-8.5.15.tar.gz
mv /tmp/apache-tomcat-8.5.15 /usr/local/tomcat
ln -s /usr/local/tomcat /opt/openemm/tomcat


function install_mysql() {
export DEBIAN_FRONTEND="noninteractive"
debconf-set-selections <<< "mysql-server mysql-server/root_password password redhat"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password redhat"
apt-get install -y mysql-server
service mysql start
apt-get install mysql-client libmysqlclient-dev -y
}

function create_mycnf() {
read -d '' MYSQL_CLIENT << EOF
[client]
user=root
password=$MYSQL_ROOT_PASSWORD
EOF

echo "${MYSQL_CLIENT}" > ~/.my.cnf
}

function install_python() {
apt-get install python-dev python-pip -y
pip install MySQL-python 
}

function install_openemm() {
OPENEMM_ARCHIVE="OpenEMM-2015_R2-bin_x64.tar.gz"

wget -O /tmp/$OPENEMM_ARCHIVE "http://downloads.sourceforge.net/project/openemm/OpenEMM%20software/OpenEMM%202015/OpenEMM-2015_R2-bin_x64.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fopenemm%2Ffiles%2FOpenEMM%2520software%2FOpenEMM%25202015%2F&ts=1459755210&use_mirror=jaist"

cd /home
mv /home/openemm /home/openemm-2015
ln -s /home/openemm-2015 /home/openemm
cd /home/openemm
tar -xzvpf /tmp/$OPENEMM_ARCHIVE

OPENEMM_DOC_DIR=/usr/share/doc/OpenEMM-2015
mkdir -p $OPENEMM_DOC_DIR
mv USR_SHARE/* $OPENEMM_DOC_DIR
rm -r USR_SHARE
chown -R openemm:openemm /home/openemm-2015

service mysql start

function setup_databases() {
echo "create database openemm" | mysql -u root -predhat
echo "create database openemm_cms" | mysql -u root -predhat

cd /usr/share/doc/OpenEMM-2015
mysql -u root -predhat openemm < openemm-2015_R2.sql
mysql -u root -predhat openemm_cms < openemm_cms-2015.sql

create_default_db_user
}

function create_default_db_user() {
echo "GRANT ALL ON *.* TO 'agnitas'@'localhost' IDENTIFIED BY 'openemm';" | mysql -u root -predhat
}

# Prepare Web Host

cd /opt/openemm/tomcat

mv conf conf-backup

ln -s /home/openemm/conf conf

# Copy my.cnf to openemm user

cp ~/.my.cnf /home/openemm/.my.cnf
chown openemm:openemm /home/openemm/.my.cnf

# Install Executable Service Manager

ln -s /home/openemm/bin/openemm.sh /usr/local/bin/openemm
}


function install_nginx() {
sleep 1 
}

function nxing_proxy_config() {
sleep 1
}


function main() {
create_user
install_prep
install_mysql
setup_databases
install_java
install_tomcat
install_python
create_mycnf
install_openemm

}

# Run Installation
main
/bin/bash 

touch /var/log/error.log
tailf /var/log/error.log
