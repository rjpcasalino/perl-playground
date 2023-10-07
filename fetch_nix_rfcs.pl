#!/usr/bin/env perl
# file: fetch_nix_rfcs.pl


use v5.10;
use warnings;
use LWP;
use HTML::TokeParser::Simple;
use constant RFCS => 'https://raw.githubusercontent.com/NixOS/rfcs/master/rfcs/';

die "Usage: fetch_nix_rfcs.pl 0001-rfc-process...\nGet full list: https://github.com/NixOS/rfcs/tree/master/rfcs\n" unless @ARGV;

my $p = HTML::TokeParser::Simple->new(url => "https://github.com/NixOS/rfcs/tree/master/rfcs");
my $ua = LWP::UserAgent->new;
my $new_agent = 'Mozilla/5.0 (' . $ua->agent . ')';
$ua->agent($new_agent);

while ( my $token = $p->get_token ) {
    # This prints all text in an HTML doc (i.e., it strips the HTML)
    next unless $token->is_text;
    # GitHub stores this shit in JSON payload on the page itself...
    say $token->as_is if ($token->as_is =~ "payload");
    if (defined (my $rfc = shift)) {
	my $url = RFCS . $rfc . ".md";
	say "Fetching: $url";

	my $response = $ua->get($url);
	say $response->decoded_content;
    }
}
