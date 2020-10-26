#!/usr/bin/env perl
# file: name_trans.pl

use 5.30.1;
use Socket;

my $ADDR_PAT = '^\d+\.\d+\.\d+\.\d+$';
while(<>) {
	chomp;
	die "$_: Not a vaild address" unless /$ADDR_PAT/o;
	my $name = gethostbyaddr(inet_aton($_), AF_INET);
	$name ||= '?';
	say "$_ => $name";
}
