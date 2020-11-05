#!/usr/bin/env perl
# file: mirror_rfc.pl


use v5.10;
use LWP;

use constant RFCS => 'http://www.faqs.org/rfcs/';

die "Usage: mirror_rfc.pl rfc1 rfc2...\n" unless @ARGV;

my $ua = LWP::UserAgent->new;
my $new_agent = 'mirror_rfc/1.0 (' . $ua->agent . ')';
$ua->agent($new_agent);

while ( defined (my $rfc = shift) ) {
	warn "$rfc: invalid RFC number\n" && next unless $rfc =~ /^\d+$/;
	my $file_name = "rfc$rfc.html";
	my $url = RFCS . $file_name;

	my $response = $ua->mirror($url, $file_name);
	print "RFC $rfc: ", $response->message, "\n";
}
