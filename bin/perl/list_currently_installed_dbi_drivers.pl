#!/usr/bin/perl

use strict;
use DBI;

my @drivers;
@drivers = DBI->available_drivers();

foreach my $dbd (@drivers) {
	print "$dbd driver is available\n";
}

exit;
