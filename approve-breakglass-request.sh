#!/bin/sh
set -e 
source $(dirname "$0")/common_funcs.sh

git pull
git checkout (git branch --sort=-committerdate | cat | cut -c 3-)

export REQUEST_COMMIT=$(git rev-list --max-count=1 HEAD)

check_signature REQUEST_COMMIT REQUESTER_PUBKEYS

git show $REQUEST_COMMIT --show-signature

echo "BREAKGLASS REQUEST IS VALID"
echo "Do you want to approve it? YES/NO:"
read CONFIRM

if [ "${CONFIRM}" != "YES" ]; then
  echo "NOT YES"
  exit 1
fi

echo "Selecting key based on current yubikey"

git config user.signingkey $(gpg --card-status | grep 'sec>' | awk '{ print $2 }' | cut -d "/" -f 2)

git commit --allow-empty -m "approve ${REQUEST_COMMIT}"
git push