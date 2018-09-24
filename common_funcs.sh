#!/bin/sh
check_signature() {
  COMMIT="${!1}"
  export GNUPGHOME=$(mktemp -d -t GPGDIR)
  echo "${!2}" | gpg --import
  COMMIT_SIG=$(git show $COMMIT --format='%G?')
  if [[ "${COMMIT_SIG:0:1}" == "U" ]] ; then
    echo "${COMMIT} verified by $(git show ${COMMIT} --format='%GS')"
  else
    echo "${1} not verifiable"
    rm -fr ${GPGDIR}
    exit 1
  fi
  rm -fr ${GNUPGHOME}
  unset GNUPGHOME
}

# get engineers public keys
export REQUESTER_PUBKEYS=$(curl $REQUESTER_PUBKEYS_URL)

# get duty officr public keys
export APPROVER_PUBKEYS=$(curl $APPROVER_PUBKEYS_URL)