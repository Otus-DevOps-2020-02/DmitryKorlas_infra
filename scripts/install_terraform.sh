#!/bin/bash
set -e

if [ -z "$1" ]
then
  echo "terraform version is not specified. Use ./install_terraform.sh 0.12.24"
  exit 1
fi

echo "Will install terraform version ${1}"

wget https://releases.hashicorp.com/terraform/"$1"/terraform_"$1"_linux_amd64.zip -O /tmp/terraform.zip
sudo unzip -o /tmp/terraform.zip -d /usr/local/bin/
