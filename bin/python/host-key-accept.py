#!/usr/bin/python

import pexpect

USER="root"
HOST="192.168.1.80"
YES="yes"
COMMAND="ssh %s@%s" % (USER, HOST)

child = pexpect.spawn(COMMAND)
child.expect("yes/no")# "*yes/no*" { send \"yes\r\";exp_continue }

child.sendline(YES)
#child.expect(pexpect.EOF)
#print child.before
