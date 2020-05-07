#!/usr/bin/env bash
set -e
export HOME=/home/vagrant
export SET_VAGRANT_AS_OWNER="sudo chown -R vagrant:vagrant /home/vagrant"
export POSTMAN_DL_URL=https://dl.pstmn.io/download/latest/linux64
export CHROME_PACKAGE=google-chrome-stable_current_amd64.deb

echo "@@@ provisioning-misc @@@"

# Install Chrome
cd ~/Downloads
if [[ ! -f $CHROME_PACKAGE ]]; then
	echo "@@@ Download Chrome @@@"
	wget -q https://dl.google.com/linux/direct/$CHROME_PACKAGE
fi
dpkg -i ./google-chrome-stable_current_amd64.deb

# Install Postman
if [[ ! -d $HOME/Apps/Postman ]]; then
	echo "@@@ Deploy Postman @@@"
	cd ~/Downloads && wget -q -O postman.tar.gz $POSTMAN_DL_URL && tar xzf postman.tar.gz 
	$SET_VAGRANT_AS_OWNER
	mv ~/Downloads/Postman ~/Apps
	ln -s ~/Apps/Postman/app/Postman ~/Desktop/Postman
fi 
cd ~ && $SET_VAGRANT_AS_OWNER
