#!/bin/sh
set -e 
source $(dirname "$0")/common_funcs.sh

# @TODO: git clone and switch to most recent branch

export REQUEST_COMMIT=$(git rev-list --max-count=1 HEAD)

export COMMIT_ID=$(git rev-list --max-count=1 HEAD)
check_signature REQUEST_COMMIT REQUESTER_PUBKEYS

echo "BREAKGLASS REQUEST IS VALID"
echo "Do you want to approve it? YES/NO:"
read CONFIRM

if [ "${CONFIRM}" != "YES" ]; then
  echo "NOT YES"
  exit 1
fi

echo "Selecting key based on current yubikey"

git config user.signingkey $(gpg --card-status | grep 'sec>' | awk '{ print $2 }' | cut -d "/" -f 2)

# @TODO: echo the siature of the most recent commit
echo "this was validated against ${URL} to be genuine"
# @TODO: echo diff of commit

echo "do you want to approve this breakglass"
# @TODO: git commit --allow-empty -m "approve ${COMMIT_ID}"
# @TODO: git push