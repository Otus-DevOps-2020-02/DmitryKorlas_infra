#!/bin/bash
set -e

if [ -z "$1" ]
then
  echo "tflint version is not specified. Use ./install_tflint.sh 0.16.0"
  exit 1
fi

echo "Will install tflint version ${1}"

wget https://github.com/terraform-linters/tflint/releases/download/v"$1"/tflint_linux_amd64.zip -O /tmp/tflint.zip
sudo unzip -o /tmp/tflint.zip -d /usr/local/bin/
