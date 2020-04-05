#!/bin/bash
set -e

gcloud compute instances create "my-reddit-full" \
	--image-family="reddit-full" \
	--machine-type="f1-micro" \
	--boot-disk-size="11" \
	--tags="puma-server"
