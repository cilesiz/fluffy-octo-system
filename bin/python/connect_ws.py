#!/usr/bin/expect -f
spawn /bin/ssh -l username -p 1010 hostname "ls -l"
expect -re "Enter passphrase for RSA key '.*': "
send "passymcgee\r"
expect eof
