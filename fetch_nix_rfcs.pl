#!/usr/bin/env perl
# file: fetch_nix_rfcs.pl


use v5.10;
use warnings;
use Data::Dumper;
use LWP;
use HTML::TokeParser::Simple;
use JSON;
use Encode qw(encode_utf8);

use constant RFCS => 'https://raw.githubusercontent.com/NixOS/rfcs/master/rfcs/';

die "Usage: fetch_nix_rfcs.pl 0001-rfc-process...\nGet full list: https://github.com/NixOS/rfcs/tree/master/rfcs\n" unless @ARGV;

my $p = HTML::TokeParser::Simple->new(url => "https://github.com/NixOS/rfcs/tree/master/rfcs");
my $ua = LWP::UserAgent->new;
my $new_agent = 'Mozilla/5.0 (' . $ua->agent . ')';
$ua->agent($new_agent);
my $data;

while ( my $token = $p->get_token ) {
    # This prints all text in an HTML doc (i.e., it strips the HTML)
    next unless $token->is_text;
    # GitHub stores this shit in JSON payload on the page itself...
    $data = JSON->new->utf8->decode(encode_utf8($token->as_is)) if ($token->as_is =~ "payload");
    if (defined (my $rfc = shift)) {
	my $url = RFCS . $rfc . ".md";
	say "Fetching: $url";

	my $response = $ua->get($url);
	say $response->decoded_content;
    }
}
my $rfcs = $data->{payload}{tree}{items};
my $name = "0039-unprivileged-maintainer";
foreach my $rfc (@$rfcs) {
 my $rfc = Dumper($rfc->{name});
 $Data::Dumper::Terse = 1;
 say $rfc;
}
