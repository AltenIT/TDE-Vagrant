#!/usr/bin/env bash
set -e
export HOME=/home/vagrant
export SET_VAGRANT_AS_OWNER="sudo chown -R vagrant:vagrant /home/vagrant"
export DEPLOY_IDE=true
export JSONSH_URL="https://raw.githubusercontent.com/dominictarr/JSON.sh/master/JSON.sh"
export LATEST_PROD_REL_URL="https://data.services.jetbrains.com/products/releases?code=IIU%2CIIC&latest=true&type=release&build="

echo "@@@ Provisioning IntelliJ @@@"
if ($DEPLOY_IDE); then
	#!/bin/bash
	echo "@@@ Yes, deploy IDE @@@"
	cd ~/Downloads/ 
	echo 'Get the latest JetBrains Idea download url from JSON respone data.'
	curl -L -s -o /tmp/temp.txt $LATEST_PROD_REL_URL
	curl -s -o /tmp/JSON.sh $JSONSH_URL && chmod +x /tmp/JSON.sh
	URL=`cat /tmp/temp.txt | /tmp/JSON.sh -b | grep "linux" | gawk '{ print $2 }' | head -n 1`
	URL=`echo "$URL" | cut -d "\"" -f 2`
	echo '@@@ I found the following url to download for Linux: ' $URL ' @@@'
	wget -q $URL
	mkdir ideaic
	tar xf ideaIC*.tar.gz --strip-components 1 -C ideaic/
    echo -e "[Desktop Entry]\n" \
	    "Name=Idea\n" \
	    "GenericName=IntelliJ Idea\n" \
	    "Comment=Edit text files\n" \
	    "Exec=/home/vagrant/Downloads/ideaic/bin/idea.sh %F\n" \
	    "Terminal=false\n" \
	    "Type=Application\n" \
	    "Icon=/home/vagrant/Downloads/ideaic/bin/idea.png\n" \
	    "Categories=Programming;IDE;\n" \
	    "StartupNotify=true" > ~/Desktop/Idea.desktop
	chmod +x ~/Desktop/Idea.desktop
fi
cd ~ && $SET_VAGRANT_AS_OWNER
