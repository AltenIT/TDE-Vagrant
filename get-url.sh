#!/bin/bash

echo 'Get the latest JetBrains Idea download url from JSON respone data.'
curl -L -s -o /tmp/temp.txt 'https://data.services.jetbrains.com/products/releases?code=IIU%2CIIC&latest=true&type=release&build=' 
URL=`cat /tmp/temp.txt | ./JSON.sh -b | grep "linux" | gawk '{ print $2 }' | head -n 1` 
echo 'I found the following url to download from: ' $URL
