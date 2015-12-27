#!/usr/bin/python

"""
USAGE:

apache_log_parser_regex.py some_log_file

"""

import sys
import re
log_line_re = re.compile(r, re.VERBOSE)

def dictify_logline(line):
    m = log_line_re.match(line)
    if m:
        groupdict = m.groupdict()
        if groupdict['bytes_sent'] == '-':
            groupdict['bytes_sent'] == '0'
        return groupdict
    else:
       return {'remote_host': None,
               'status': None,
               'bytes_sent': "0",
               }

def generate_log_report(logfile):
    ''' return a dictionary of format remote_host=>[list of bytes sent]
    '''

    report_dict = {}
    for line in logfile:
        line_dict = dictify_logline(line)
        print line_dict
        try:
          bytes_sent = int(line_dict['bytes_sent'])
        except ValueError:
            ##totaly disregard anything we dont understand
            continue
        report_dict.setdefault(line_dict['remote_host'], []).append(bytes_sent)
    return report_dict

if __name__ == "__main__":
    if not len(sys.argv) > 1:
        print __doc__
        sys.exit(1)
    infile_name = sys.argv[1]
    try:
       infile = open(infile_name, 'r')
    except IOError:
       print "You must specify a valid file to parse"
       print __doc__
       sys.exit(1)
    log_report = generate_log_report(infile)
    print log_report
    infile.close()

