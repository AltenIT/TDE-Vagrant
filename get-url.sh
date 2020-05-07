#!/bin/bash

echo "@@@ Deploy the IDE @@@"
cd ~/Downloads/ 
echo 'Get the latest JetBrains Idea download url from JSON respone data.'
curl -L -s -o /tmp/temp.txt 'https://data.services.jetbrains.com/products/releases?code=IIU%2CIIC&latest=true&type=release&build=' 
curl -s -o /tmp/JSON.sh 'https://raw.githubusercontent.com/dominictarr/JSON.sh/master/JSON.sh' && chmod +x /tmp/JSON.sh
URL=`cat /tmp/temp.txt | /tmp/JSON.sh -b | grep "linux" | gawk '{ print $2 }' | head -n 1`
URL=`echo "$URL" | cut -d "\"" -f 2`
echo 'I found the following url to download from: ' $URL
wget -q $URL
