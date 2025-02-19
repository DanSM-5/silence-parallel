#!/bin/bash

cd $(dirname $0)
vagrantid=$(pwd | perl -pe 's:.*/([^/]+/[^/]+):$1:')
# centos9s
vagrantid="$vagrantid"s
echo $vagrantid
url=$(curl -s https://vagrantcloud.com/api/v2/vagrant/$vagrantid | jq -r '[.versions[] | select(.providers[].name=="virtualbox")] | max_by(.version) .providers[] | select(.name=="virtualbox") .url')
wget -N $url
vagrant box add --name $vagrantid vagrant.box
vagrant box list

