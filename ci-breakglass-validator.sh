#!/bin/sh
set -e 
source $(dirname "$0")/common_funcs.sh

export REQUEST_COMMIT=$(git rev-list --max-count=1 HEAD^1)
export APPROVAL_COMMIT=$(git rev-list --max-count=1 HEAD)

#validate REQUEST_COMMIT signature against engineer keys
check_signature REQUEST_COMMIT REQUESTER_PUBKEYS

#validate APPROVAL_COMMIT signature against duty officer keys
check_signature APPROVAL_COMMIT APPROVER_PUBKEYS

#validate APPROVAL_COMMIT message
APPROVAL_MESSAGE=$(git show --pretty=tformat:%B ${APPROVAL_COMMIT})

if [ "${APPROVAL_MESSAGE}" == "approve ${REQUEST_COMMIT}" ] ; then
  echo "${APPROVAL_COMMIT} approved ${REQUEST_COMMIT}"
else
  echo "commit message of approval is not valid"
  exit 1
fi

echo "BREAKGLASS IS VALID"
exit 0