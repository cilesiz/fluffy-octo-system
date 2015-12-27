#!/usr/bin/perl

use warnings;
use strict;

my $testFile = "/Users/ross/testing/perl/tmp/testing.txt";

open FILE, $testFile or die $!;
my $lineo = 1;
#
# if the below file doesnt exist create it - check sysadmin cookbook
#my $statFile = "~/var/tmp/rosstest/statFile.log"

#my $statFileWin = "c:/rosstest/statFile.log"

while (<FILE>) {
	print $lineo++;
	print ": $_";
}
