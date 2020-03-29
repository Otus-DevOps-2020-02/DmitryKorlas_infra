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
wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org

sudo systemctl start mongod

# add mongo to autorun
sudo systemctl status mongod
sudo systemctl enable mongod

# install reddit demo app
sudo -i -u appuser bash << EOF
cd /home/appuser
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
ps aux | grep puma
EOF
