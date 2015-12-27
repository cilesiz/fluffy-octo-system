#!/usr/bin/perl

use strict;
use DBI;

my @drivers;
@drivers = DBI->available_drivers;

foreach my $driver (@drivers) {
	print "$driver driver is available\n"
	my @dsns = DBI->data_sources($driver);
	foreach my $dsn (@dsns) {
		print "\tDSN: $dsn\n";
	}
}
