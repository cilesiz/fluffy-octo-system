#!/usr/bin/perl
# files.pl by Bill Weinman <http://bw.org/contact/>
# Copyright (c) 2010 The BearHeart Group, LLC
#
use strict;
use warnings;

use IO::File;

#my writeTestingLog = "/Users/ross/testing/writetesting.log";

#my readTestingLog = "/Users/ross/testing/readtesting.log";
main(@ARGV);

sub main
{
#    open(FH, '<', '/Users/ross/testing/readtesting.txt') or error("cannot open file ($!)");
#    open(NFH, '>', '/Users/ross/testing/writetesting.log') or error("cannot open file ($!)");
#    print NFH while <FH>;
#    close FH;
#    close NFH;
	my $fh = IO::File->new("/Users/ross/testing/readtesting.log", 'r') or error("cant open file for read ($!)");
	my $nfh = IO::File->new("/Users/ross/testing/writetesting.log", 'w') or error("cant open file for write ($!)");
	while (my $line = $fh->getline) {
		$nfh->print($line);
	}
}


sub message
{
    my $m = shift or return;
    print("$m\n");
}

sub error
{
    my $e = shift || 'unkown error';
    print(STDERR "$0: $e\n");
    exit 0;
}

