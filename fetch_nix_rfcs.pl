#!/usr/bin/env perl
# file: fetch_nix_rfcs.pl


use v5.10;
use warnings;
use LWP;

use constant RFCS => 'https://raw.githubusercontent.com/NixOS/rfcs/master/rfcs/';

die "Usage: fetch_nix_rfcs.pl rfc1...\n" unless @ARGV;

my $ua = LWP::UserAgent->new;
my $new_agent = 'Mozilla/5.0 (' . $ua->agent . ')';
$ua->agent($new_agent);

while ( defined (my $rfc = shift) ) {
	my $url = RFCS . $rfc;
	say "Fetching: $url";

	my $response = $ua->get($url);
	say $response->decoded_content;
}
