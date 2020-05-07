#!/usr/bin/env bash
set -e
export HOME=/home/vagrant
export TOMCAT_VERSION=8.5.54
export SET_VAGRANT_AS_OWNER="sudo chown -R vagrant:vagrant /home/vagrant"
# dl urls
export TOMCAT_DL_URL=https://archive.apache.org/dist/tomcat/tomcat-8/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
export CATALINA_HOME=$HOME/Apps/apache-tomcat-$TOMCAT_VERSION
echo "@@@ provisioning - Tomcat and Jenkins @@@"

#Tomcat
cd ~/Apps
if [[ ! -d ./$TOMCAT_VERSION ]]; then
		echo "Create Tomcat directory"
		if [[ ! -f apache-tomcat-$TOMCAT_VERSION.tar.gz ]]; then
			echo "Tomcat not found, dl version ${TOMCAT_VERSION}"
			wget -q $TOMCAT_DL_URL
		fi
		tar xzf apache-tomcat-$TOMCAT_VERSION.tar.gz
fi
#Jenkins
cd ~/Downloads
if [[ ! -f jenkins.war ]]; then 
	wget -q http://mirrors.jenkins.io/war-stable/latest/jenkins.war
fi
if [[ -f $CATALINA_HOME/webapps/jenkins.war ]]; then
	rm $CATALINA_HOME/webapps/jenkins.war
fi
mv jenkins.war $CATALINA_HOME/webapps

# start tomcat 
$CATALINA_HOME/bin/startup.sh
cd ~ && $SET_VAGRANT_AS_OWNER
