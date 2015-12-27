#!/usr/bin/perl

use warnings;
use strict;

my $lineo = 1;

while (<>) {
	print $lineo++;
	print ": $_";
}
