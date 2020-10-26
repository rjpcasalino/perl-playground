#!/usr/bin/env perl
# file: ip_trans.pl

use 5.30.1;
use Socket;

# Witness the glory of perl!
while (<>) {
	chomp; # avoid \n on last field
	my $packed_address = gethostbyname($_);
	unless ($packed_address) {
		say "$_ => ?";
		next;
	}
	my $dotted_quad = inet_ntoa($packed_address);
	say "$_ => $dotted_quad";
}
1;
