#!/usr/bin/env perl
# file: ip_trans2.pl

use v5.30.1;
use Socket qw(:addrinfo SOCK_RAW);

# "Oooh, weird science
# Magic and technology
# Voodoo dolls and chants." 

while (<>) {
	chomp;
	my ($err, @res) = getaddrinfo($_, "", {socktype => SOCK_RAW});
	die "Cannot getaddrinfo - $err" if $err;
	# it's alive! 
	while( my $ai = shift @res ) {
		# what the heck is NIx_NOSERV?
		# ...'no service' something NIx?
		# NI?
		# checks further up perldoc Socket ... 
		# ... ... 
		# ...ah, yes, I see...
		# * shrugs *
		my ($err, $ipaddr) = getnameinfo($ai->{addr}, NI_NUMERICHOST, NIx_NOSERV);
		die "Cannot getnameinfo - $err" if $err;
		
		print "$ipaddr\n";
		# why not just...
		# say "$ipaddr?";
	}
}
