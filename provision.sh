#!/usr/bin/env bash
set -e
export HOME=/home/vagrant
export IDEA_IC_VERSION=ideaIC-2018.3.2
export SET_VAGRANT_AS_OWNER="sudo chown -R vagrant:vagrant /home/vagrant"
export FLYWAY_VERSION=4.2.0

echo  provisioning the Virtual machine

echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/webupd8team-java.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | sudo tee -a /etc/apt/sources.list.d/webupd8team-java.list
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
sudo apt-get update
sudo apt-get install -y build-essential
sudo apt-get install -y libmysqlclient-dev
sudo apt-get install -y git
sudo apt-get install -y firefox-esr #browsers #sudo apt-get install -y google-chrome-stable
sudo apt-get install -y oracle-java8-installer
sudo apt-get install -y oracle-java8-set-default
sudo apt-get install -y maven

#mysql password
debconf-set-selections <<< 'mysql-server mysql-server/root_password password vagrant'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password vagrant'
sudo apt-get install -y --force-yes mysql-server
sudo dpkg --configure -a

if [[ ! -d ./SimpleBlog ]]; then
    echo  SimpleBlog directory does not exist create it.
    git clone https://github.com/endegraaf/SimpleBlog.git
else
    cd SimpleBlog
    git pull
    cd $HOME
fi

$SET_VAGRANT_AS_OWNER

# Flyway
echo  Install Flyway version $FLYWAY_VERSION database migration
cd $HOME
if [[ ! -d ./Flyway ]]; then
    mkdir Flyway && cd Flyway
    wget -q https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/$FLYWAY_VERSION/flyway-commandline-$FLYWAY_VERSION-linux-x64.tar.gz
    tar xzf flyway-commandline-4.2.0-linux-x64.tar.gz
fi
export PATH=$PATH:$HOME/Flyway/flyway-$FLYWAY_VERSION

# spring-security-facelets-taglib mirror
cd $HOME
if [[ ! -d ./spring-security-facelets-taglib ]]; then
    git clone https://github.com/domdorn/spring-security-facelets-taglib.git
fi
cd spring-security-facelets-taglib
mvn clean install -DskipTests #skip tests because of the embedded selenium one.

cd $HOME
# SimpleBlog code
if [[ ! -d ./SimpleBlog ]]; then
    git clone https://github.com/endegraaf/SimpleBlog.git
fi

cd SimpleBlog
git pull

cd $HOME && $SET_VAGRANT_AS_OWNER


# Mysql Local database
echo Create a local Database
mysql --user=root --password=vagrant --execute="DROP DATABASE if exists blog; CREATE DATABASE blog CHARACTER SET utf8;"
mysql --user=root --password=vagrant --execute="GRANT USAGE ON *.* TO 'bloguser'@'localhost';DROP USER 'bloguser'@'localhost';"
mysql --user=root --password=vagrant --execute="CREATE USER 'bloguser'@'localhost' IDENTIFIED BY 'blogpassword';"
mysql --user=root --password=vagrant --execute="GRANT ALL PRIVILEGES ON blog.* TO 'bloguser'@'localhost' WITH GRANT OPTION;"

cd $HOME && cd SimpleBlog

flyway  -baselineOnMigrate=true -url=jdbc:mysql://localhost/ -schemas=blog -user=bloguser -password=blogpassword -locations=filesystem:src/main/resources/db/migration/ migrate


# Ide
cd ~/Downloads/ 
if [[ ! -d ./$IDEA_IC_VERSION ]]; then
    wget -q https://download.jetbrains.com/idea/$IDEA_IC_VERSION.tar.gz
    mkdir $IDEA_IC_VERSION
    tar xzf $IDEA_IC_VERSION.tar.gz --strip-components 1 -C ./$IDEA_IC_VERSION/
    echo -e "[Desktop Entry]\n" \
    "Name=Idea\n" \
    "GenericName=IntelliJ Idea\n" \
    "Comment=Edit text files\n" \
    "Exec=/home/vagrant/Downloads/$IDEA_IC_VERSION/bin/idea.sh %F\n" \
    "Terminal=false\n" \
    "Type=Application\n" \
    "Icon=/home/vagrant/Downloads/$IDEA_IC_VERSION/bin/idea.png\n" \
    "Categories=Programming;IDE;\n" \
    "StartupNotify=true" > ~/Desktop/Idea.desktop
fi

cd $HOME && $SET_VAGRANT_AS_OWNER

cd $HOME && cd SimpleBlog
mvn clean install

echo -e "#!/bin/sh\n" \
"cd /home/vagrant/SimpleBlog\n" \
"mvn tomcat7:run-war" > ~/Start-SimpleBlog.sh

chmod +x ~/Start-SimpleBlog.sh


echo -e "[Desktop Entry]\n" \
    "Name=Run SimpleBlog\n" \
    "GenericName=SimpleBlog\n" \
    "Exec=/home/vagrant/Start-SimpleBlog.sh %F\n" \
    "Terminal=true\n" \
    "Type=Application\n" \
    "Icon=" \
    "Categories=" \
    "StartupNotify=false" > ~/Desktop/Start-SimpleBlog.desktop

chmod +x ~/Desktop/Start-SimpleBlog.desktop

cp -r /root/.m2 /home/vagrant

chown -R vagrant:vagrant /home/vagrant



