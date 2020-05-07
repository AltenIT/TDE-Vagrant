#!/usr/bin/env bash
set -e
export HOME=/home/vagrant
export DEPLOY_SUT=true
export SET_VAGRANT_AS_OWNER="sudo chown -R vagrant:vagrant /home/vagrant"
export JUNIT_VERSION=4.13-beta-3
export HAMCREST_VERSION=1.3
export GIT_BASE_URL=https://github.com/AltenIT
export SUT_NAME=springmvc-shoppingcart-sample
export APITEST_NAME=Rest-Assured 
export GUITEST_NAME=SeleniumBDD
#Compute correct git urls
export SUT_GIT_URL=$GIT_BASE_URL/$SUT_NAME.git
export APITEST_GIT_URL=$GIT_BASE_URL/$APITEST_NAME.git
export GUITEST_GIT_URL=$GIT_BASE_URL/$GUITEST_NAME.git

echo "@@@ provisioning-base @@@"

apt update
apt install -y build-essential
apt install -y libmysqlclient-dev
apt install -y git
apt install -y openjdk-8-jdk
apt install -y maven
apt install -y libgconf2-4
apt install -y gnome-session-flashback
apt install -y tigervnc-standalone-server
apt install -y mc
apt install -y curl
apt install -y gawk
apt install -y docker.io

# add vagrant to docker group
usermod -G docker vagrant

#Ubuntu creates user home folders too late, so create them on forehand
if [[ ! -d ~/Downloads ]]; then
	mkdir ~/Downloads
	mkdir ~/Desktop 
	mkdir ~/Apps
fi
$SET_VAGRANT_AS_OWNER


if ($DEPLOY_SUT); then

	echo "@@@ Yes, deploy SUT and test frameworks @@@"
	cd $HOME
	# Install SUT from GIT #
	if [[ -d ./$SUT_NAME ]]; then
		echo "Remove old dir in image: " $SUT_NAME
		rm -rf ./$SUT_NAME
	fi
	git clone $SUT_GIT_URL
	cd $SUT_NAME
	mvn clean install
	cd ~ 

	# Install API test #
	if [[ -d ./$APITEST_NAME ]]; then
		echo "Remove old dir in image. " $APITEST_NAME 
		rm -rf $APITEST_NAME
	fi
	git clone $APITEST_GIT_URL && cd $APITEST_NAME
	mvn clean compile
	cd ~ 

	# Install GUI test #
	if [[ -d ./$GUITEST_NAME ]]; then
		echo "Remove old dir in image. " $GUITEST_NAME
		rm -rf $GUITEST_NAME
	fi
	git clone $GUITEST_GIT_URL && cd $GUITEST_NAME
	mvn clean compile

	cp -r /root/.m2 /home/vagrant
	$SET_VAGRANT_AS_OWNER

	cd ~ 
	echo "@@@ Shortcut for starting the SUT @@@"
	echo -e '#!/bin/bash\n' \
	'cd /home/vagrant/'$SUT_NAME'/\n' \
	'mvn clean jetty:run' > ~/Start-$SUT_NAME.sh
	chmod +x ~/Start-$SUT_NAME.sh
	echo -e "[Desktop Entry]\n" \
	    "Name=Run $SUT_NAME\n" \
	    "GenericName=$SUT_NAME\n" \
	    "Exec=/home/vagrant/Start-$SUT_NAME.sh %F\n" \
	    "Terminal=true\n" \
	    "Type=Application\n" \
	    "Icon=" \
	    "Categories=" \
	    "StartupNotify=false" > ~/Desktop/Start-$SUT_NAME.desktop
	chmod +x ~/Desktop/Start-$SUT_NAME.desktop
fi
echo "@@@ Junit and Hamcrest Libs, set .bash_profile and .bashrc @@@"
echo -e "export CLASSPATH=$CLASSPATH:$HOME/Libs/hamcrest-core-1.3.jar:$HOME/Libs/junit-4.13-beta-3.jar" > ~/.bash_profile
echo -e "alias ll='ls -ltr'\nalias la='ls -latr'\nalias l='ls -l'\n" > ~/.bashrc

if [[ ! -d ~/Libs ]]; then
		echo "Create Libs directory"
		mkdir ~/Libs
fi
cd ~/Libs
if [[ ! -f hamcrest-core-$HAMCREST_VERSION.jar ]]; then
	wget -q https://repo1.maven.org/maven2/org/hamcrest/hamcrest-core/$HAMCREST_VERSION/hamcrest-core-$HAMCREST_VERSION.jar
fi
if [[ ! -f junit-$JUNIT_VERSION.jar ]]; then
	wget -q https://repo1.maven.org/maven2/junit/junit/$JUNIT_VERSION/junit-$JUNIT_VERSION.jar
fi
cd ~
$SET_VAGRANT_AS_OWNER
