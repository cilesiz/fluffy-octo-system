#!/usr/bin/perl

use DBI;
use strict;

my $dbh = DBI->connect("dbi:mysql:mysql:192.168.1.100","dbuser","dbpassword");

# 2nd way

use DBI;
use strict;
my $username = "dbuser";
my $password = "dbpassword";

