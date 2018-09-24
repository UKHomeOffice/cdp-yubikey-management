# CDP yubikey mannagement

We issue our engineers with [YubiKeys](https://www.yubico.com/products/yubikey-hardware/) so that they can sign code and also use for ssh authentication.

This repository contains the code we use for provisioning YubiKeys and the scripts we run in CI for validating the authenticity of commits and system actions (breakglass) that require multiple keys to interact to prove validity and authorisation.

## [provision_card.sh](./provision_card.sh)
This will provision the yubikey, it is designed to be run on a managed device, which has the following dependencies: 
 - [expect](https://www.tcl.tk/man/expect5.31/expect.1.html)
 - [GPG](https://gnupg.org)
 - [ykman](https://developers.yubico.com/yubikey-manager/)

The script:
 - Factory resets the yubikey
 - Configures the yubikey to generate a `4096-bit` key
 - Generates the key on the yubikey itself to avoid the key being backed up, or stored anywhere apart from the key itself
 - Personalizes the admin key and user key of the device

## [ci-breakglass-validator.sh](./ci-breakglass-validator.sh)
This is run by the CI platform to validate the breakglass request prior to executing.

Dependencies:
 - [gpg](https://gnupg.org)
 - [git](https://git-scm.com/)

The script:
 - Retrieves the current valid requester public keys
 - Retrieves the current valid approver public keys
 - Validates that the prenultiamte (`HEAD^1`) commit was signed by a valid requester
 - Validates that the ultimate (`HEAD`) commit was signed by a valid approver
 - Validates that the ultimate (`HEAD`) commit references the prenultiamte (`HEAD^1`)commit

## [approve-breakglass-request.sh](./approve-breakglass-request.sh)
This is run by an approver to approve the engineer's breakglass request.
 
Dependencies:
 - [git](https://git-scm.com/)
 - [gpg](https://gnupg.org)
 - [yubikey](https://www.yubico.com/products/yubikey-hardware/)

The script:
 - Retrieves the current valid requester public keys
 - Validates that the ultimate (`HEAD`) commit was signed by a valid requester
 - Displays the diff of the requesting commit
 - On confirmation from the approver creates an empty commit referencing the requesting commit in the commit message that is signed with the currently inserted yubikey