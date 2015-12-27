#!/usr/bin/python
"""
USAGE:

apache_log_parser_split.py some_log_file

This script takes one command line arguement: the name of a log file
to parse. It then parses the log file and generates a report which
associates remote hosts with number of bytes transfered to them.
"""

import sys

def dictify_logline(line):
    '''return a dictionary of the pieces of the apache log file we are
    interested in

    Currently, only fields we are interested in are mote host and bytes sent.
    '''
    split_line = line.split()
    return {'remote_host': split_line[0],
            'status': split_line[8],
            'bytes_sent': split_line[9],
    }

def generate_log_report(logfile):
    '''return a dictionary of format remote host=>[list of bytes sent]

    This function takes a file object, iterates through all the lines in the file,
    and generates a report of the number of bytes transfered to each remote host
    for each hit on the webserver.
    '''
    report_dict = {}
    for line in logfile:
        line_dict = dictify_logline(line)
        print line_dict
        try:
           bytes_sent = int(line_dict['bytes_sent'])
        except ValueError:
           ##totaly disregard anything the script doesnt understand
           continue
        report_dict.setdefault(line_dict['remote_host'], []).append(bytes_sent)
    return report_dict
    if __name__ == "__main__":
         if not len(sys.argv) > 1:
             print __doc__
             sys.exit(1)
    infile_name = sys.argv[1]
    try:
        infile = open(infile_name,  'r')
    except IOError:
       print "You must specify a vlid file to parse"
       print __doc__
       sys.exit(1)
       log_report = generate_log_report(infile)
       print log_report
       infile.close()

