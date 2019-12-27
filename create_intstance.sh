#!/bin/bash

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 > startup.log 2>&1
curl -sSL https://get.rvm.io | bash -s stable > startup.log 2>&1
source ~/.rvm/scripts/rvm > startup.log 2>&1
rvm requirements > startup.log 2>&1
rvm install 2.4.1 > startup.log 2>&1
rvm use 2.4.1 --default > startup.log 2>&1
gem install bundler -V --no-ri --no-rdoc > startup.log 2>&1

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 > startup.log 2>&1
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list' > startup.log 2>&1
sudo apt-get update > startup.log 2>&1
sudo apt-get install -y mongodb-org > startup.log 2>&1
sudo systemctl start mongod > startup.log 2>&1
sudo systemctl enable mongod > startup.log 2>&1

git clone https://github.com/Artemmkin/reddit.git > startup.log 2>&1
cd reddit && bundle install > startup.log 2>&1
puma -d > startup.log 2>&1
