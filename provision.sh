#!/usr/bin/env bash
set -e
export HOME=/home/vagrant
export DEPLOY_IDE=true
# dependency and sw versions
export JUNIT_VERSION=4.13-beta-3
export HAMCREST_VERSION=1.3
export IDEA_IC_VERSION=ideaIC-2018.3.2
export TOMCAT_VERSION=8.5.42
# dl urls
export TOMCAT_DL_URL=http://apache.proserve.nl/tomcat/tomcat-8/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
export CATALINA_HOME=$HOME/Apps/apache-tomcat-$TOMCAT_VERSION
export POSTMAN_DL_URL=https://dl.pstmn.io/download/latest/linux64
export CHROME_PACKAGE=google-chrome-stable_current_amd64.deb
export GIT_BASE_URL=https://github.com/AltenIT
export SUT_NAME=springmvc-shoppingcart-sample
export APITEST_NAME=Rest-Assured 
export GUITEST_NAME=SeleniumBDD
#Compute correct git urls
export SUT_GIT_URL=$GIT_BASE_URL/$SUT_NAME.git
export APITEST_GIT_URL=$GIT_BASE_URL/$APITEST_NAME.git
export GUITEST_GIT_URL=$GIT_BASE_URL/$GUITEST_NAME.git
#commands
export SET_VAGRANT_AS_OWNER="sudo chown -R vagrant:vagrant /home/vagrant"

echo provisioning the Virtual machine

# echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/webupd8team-java.list
# echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | sudo tee -a /etc/apt/sources.list.d/webupd8team-java.list
# echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
# echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
# apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

# echo  Remove original sources list and provide own
# rm /etc/apt/sources.list

# echo -e "deb http://http.debian.net/debian jessie main\n" \
#     "deb-src http://http.debian.net/debian jessie main\n" \
#     "deb http://security.debian.org/ jessie/updates main contrib\n" \
#     "deb-src http://security.debian.org/ jessie/updates main contrib" > /etc/apt/sources.list

apt-get update
apt-get install -y build-essential
apt-get install -y libmysqlclient-dev
apt-get install -y git
# apt-get install -y firefox-esr
apt-get install -y openjdk-8-jdk
# apt-get install -y oracle-java8-set-default
apt-get install -y maven
# apt-get install -y libappindicator3-1 


echo @@@ Deploy SUT @@@
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
cd ~ 

$SET_VAGRANT_AS_OWNER

# Install Chrome
if [[ ! -d ~/Downloads ]]; then
	mkdir ~/Downloads
fi
cd ~/Downloads

if [[ ! -f $CHROME_PACKAGE ]]; then
	echo "Download Chrome"
	wget -q https://dl.google.com/linux/direct/$CHROME_PACKAGE
fi
dpkg -i ./google-chrome-stable_current_amd64.deb
cd ~ 

#Tomcat
if [[ ! -d ~/Apps ]]; then
	mkdir ~/Apps	
fi
cd ~/Apps
if [[ ! -d ./$TOMCAT_VERSION ]]; then
		echo "Create Tomcat directory"
		if [[ ! -f apache-tomcat-$TOMCAT_VERSION.tar.gz ]]; then
			wget -q $TOMCAT_DL_URL
		fi
		tar xzf apache-tomcat-$TOMCAT_VERSION.tar.gz
fi
cd ~

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

# Ide
if [[ $DEPLOY_IDE ]]; then
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
fi
cd ~ 

echo -e "#!/bin/sh\n" \
"cd /home/vagrant/$SUT_NAME/\n" \
"mvn clean jetty:run" > ~/Start-$SUT_NAME.sh

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

cp -r /root/.m2 /home/vagrant
$SET_VAGRANT_AS_OWNER

if [[ ! -d $HOME/Apps/Postman ]]; then
	echo @@@ Deploy Postman @@@
	cd ~/Downloads && wget -q -O postman.tar.gz $POSTMAN_DL_URL && tar xzf postman.tar.gz 
	$SET_VAGRANT_AS_OWNER
	mv ~/Downloads/Postman ~/Apps
	ln -s ~/Apps/Postman/app/Postman ~/Desktop/Postman
fi 

echo @@@ Junit and Hamcrest Libs, set .bash_profile @@@

echo -e "export CLASSPATH=$CLASSPATH:$HOME/Libs/hamcrest-core-1.3.jar:$HOME/Libs/junit-4.13-beta-3.jar" > ~/.bash_profile

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
