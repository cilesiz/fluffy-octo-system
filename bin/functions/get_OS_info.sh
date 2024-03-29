function get_OS_info
{
# For a few commands it is necessary to know the OS to
# execute the proper command syntax.  This will always
# return the Operating System in UPPERCASE characters

typeset -u OS  # Use the UPPERCASE values for the OS variable
OS=`uname`     # Grab the Operating system, i.e. AIX, HP-UX
print $OS      # Send back the UPPERCASE value
}
get_OS_info
