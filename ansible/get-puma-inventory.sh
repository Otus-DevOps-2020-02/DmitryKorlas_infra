#!/bin/bash
set -e

GCLOUD_PUMA_RESULT=$(gcloud compute instances list --format="value(name, EXTERNAL_IP)")

# expected output format is
# reddit-app      35.233.22.159
# reddit-db       35.187.100.57


# converting gcloud output into the array. tricky bash scripting.
# https://www.oreilly.com/library/view/bash-cookbook/0596526784/ch13s04.html
declare -a RESULT
RESULT=($GCLOUD_PUMA_RESULT)

cat <<EOF
{
  "${RESULT[0]}": {
    "hosts": ["${RESULT[1]}"]
  },
  "${RESULT[2]}": {
    "hosts": ["${RESULT[3]}"]
  }
}
EOF
