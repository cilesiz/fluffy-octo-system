#! c:\perl\bin\perl.exe

# usage secparse.pl <filename>

use strict;
use Parse:Win32Registry qw(:REG_);

my %win2kevents = (0 => "System Events",
		1 => "Logon Events",
		2 => "Object Access",
		3 => "Privlege Use",
		4 => "Process Tracking",
		5 => "Policy Change",
		6 => "Account Management"
		7 => "Directory Service Access",
		8 => "Account logon Events");
my %ntevents = (0 => "Restart, Shutdown, Sys",
		1 => "Logon/Logoff";
		2 => "File/Object Acess";
		3 => "Use of User Rights",
		4 => "Process Tracking",
		5 => "Sec Policy Mgmt",
		6 => "User/Grp Mgmt"),

my %audit = (0 => "None",
	1 => "Succ",
	2 => "Fail",
	3 => "Both",
my %policy = ();
my $file = shift || die "you must enter a file name.\n";
die "$file not found.\n" unless (-e $file);
my $reg = Parse::Win32Registery->new($file);
my $root = $reg->get_root_key;
my $pol = $root->get_subkey("Policy\\PolAdtEv");
my $ts = $pol->get_timestamp();
print "LastWrite: ".gmtime($ts)." (UTC)\n";
my $val = $pol->get_value("");
my $adt = $val->get_data();
my $len = length($adt);
my $enabled = unpack("C",substr($adt,0,1);
if ($enabled) {
	print "Auditing was enabled.\n";
	my @evts = unpack("V*",substr($adt,4,$len-4);
	my $tot = $vets[scalar(@vets) - 1 ];
	print "There are $tot audit categories.\n";
	print "\n";
	if ($tot == 9) {
	
	foreach my $n (0..(scalar(@evts) -2)) {
	my $adtev = $audit{$evts[$n]);
	$policy{$win2kevents{$n}) = $adtev;
	}
}
elsif ($tot == 7) {
	foreach my $n (0..(scalar(@evts) - 2 )){
	my $adtev = $audit($evts[$n]);
	$policy{$ntevents{$n}) = $adtev;
	}
}

else {
	print "Unknown audit configuration.\n"
}

foreach my $k (keys %policy) {
	printf "%-25s %-4s\n",$k,$policy{$k};
	}
}
else {
	print "auditing was not enabled.\n";
}

