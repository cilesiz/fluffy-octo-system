#!/usr/bin/env python

# import the optparse and pexpect module
from optparse import OptionParser
import pexpect

def main():
  parser = OptionParser()
  parser.add_option("--hostname", dest="hostname")
  parser.add_option("--ip", dest="ip")
  (options, args) = parser.parse_args()
  USER="root"
  YES="yes"
  IP = options.ip
  HOST = options.hostname

  # hacked together way of making ssh run twice
  for name in [HOST, IP]:

    COMMAND="ssh %s@%s" % (USER, name)
    child = pexpect.spawn(COMMAND)
    child.expect("yes/no")#
    child.sendline(YES)

# run the main function

if __name__ == "__main__":
    main()

