#!/usr/bin/env expect -f

send_user -- "Your name: "
expect_user -re "(.*)\n"
set comment "created by $expect_out(1,string)"

send_user -- "Card holder forename: "
expect_user -re "(.*)\n"
set cardholder_forname $expect_out(1,string)

send_user -- "Card holder surname: "
expect_user -re "(.*)\n"
set cardholder_surname $expect_out(1,string)

send_user -- "Card holder email address: "
expect_user -re "(.*)\n"
set cardholder_email $expect_out(1,string)

send_user -- "\nProvisioning a YubiKey for $cardholder_forname $cardholder_surname | $cardholder_email | $comment\n"
send_user -- "In 10 seconds this will destructively without further prompt provision the currently inserted yubikey\n\n"

sleep 10

set prompt "gpg/card\>"
set keyprompt "\\? "

eval spawn ykman openpgp reset
send "y\r"
expect "Success"
expect eof

eval spawn gpg --card-edit
expect "Yubico Yubikey"
expect $prompt
send "admin\r"
expect $prompt
send "key-attr\r"

expect "Signature key"
expect "(1) RSA"
send "1\r"
expect "What keysize do you want"
send "4096\r"

expect "Encryption key"
expect "(1) RSA"
send "1\r"
expect "What keysize do you want"
send "4096\r"

expect "Authentication key"
expect "(1) RSA"
send "1\r"
expect "What keysize do you want"
send "4096\r"

expect $prompt
send "generate\r"
expect "Make off-card backup of encryption key"
send "n\r"
expect "Key is valid for"
send "52w\r"
expect "Is this correct?"
send "y\r" 

expect "Real name:"
send "$cardholder_forename $cardholder_surname\r"
expect "Email address"
send "$cardholder_email\r"
expect "Comment"
send "$comment\r"
expect "(O)kay"
send "O\r" 

interact -o -nobuffer -re $prompt return

send "name\r"
expect "surname"
send "$cardholder_surname\r"
expect "given name"
send "$cardholder_forename\r"

expect $prompt
send "passwd\r"
expect "1 - change PIN"
send "1\r"
interact -o -nobuffer -re "PIN changed." return
expect "3 - change Admin PIN"
send "3\r"
interact -o -nobuffer -re "PIN changed." return
send "Q\r"

expect $prompt
send  "Q\r"

expect eof

eval spawn ykman openpgp touch aut on
expect "Set touch policy of AUTHENTICATE"
send "y\r"
expect "Enter admin PIN:"
interact -o -nobuffer -re "Touch policy successfully set" return
expect eof


eval spawn ykman openpgp touch enc on
expect "Set touch policy of ENCRYPT"
send "y\r"
expect "Enter admin PIN:"
interact -o -nobuffer -re "Touch policy successfully set" return
expect eof


eval spawn ykman openpgp touch sig on
expect "Set touch policy of SIGN"
send "y\r"
expect "Enter admin PIN:"
interact -o -nobuffer -re "Touch policy successfully set" return
expect eof

eval spawn gpg --armor --export $email
expect "END PGP PUBLIC KEY BLOCK"
expect eof