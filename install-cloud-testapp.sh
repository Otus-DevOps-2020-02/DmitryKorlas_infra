#!/bin/bash

echo "whoami: $(whoami)"
echo "pwd: $(pwd)"
# echo "list users: $(cut -d: -f1 /etc/passwd)"

# install ruby
sudo apt-get update
sudo apt-get --assume-yes install ruby-full ruby-bundler build-essential

# install mongodb 4 (failed on CI tests)
# wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
# sudo apt-get --assume-yes install gnupg
# wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
# echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list

# install mongodb 3
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

sudo apt-get update
sudo apt-get --assume-yes install mongodb-org

sudo tee /etc/systemd/system/mongodb.service > /dev/null <<EOT
[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target

[Service]
User=mongodb
ExecStart=/usr/bin/mongod --quiet --config /etc/mongod.conf

[Install]
WantedBy=multi-user.target
EOT

# start mongo
sudo systemctl start mongodb

# add mongo to autorun
sudo systemctl enable mongodb

# install reddit demo app
sudo -i -u appuser bash << EOF
cd /home/appuser
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
ps aux | grep puma
EOF
