#!/usr/bin/env perl
# file: fetch_nix_rfcs.pl

use v5.10;
use warnings;
use Data::Dumper;
use LWP;
use HTML::TokeParser::Simple;
use JSON;
use Encode qw(encode_utf8);
use Getopt::Long qw(GetOptions);
$Data::Dumper::Terse = 1;

my %opts     = ( list => '', rfc => '');
GetOptions(
    \%opts, qw(
      list
      rfc
      )
);

use constant RFCS => 'https://raw.githubusercontent.com/NixOS/rfcs/master/rfcs/';

die "Usage: fetch_nix_rfcs.pl --rfc 0001-rfc-process...\nGet full list: --list\n" unless $opts{list} || $opts{rfc};

my $p = HTML::TokeParser::Simple->new(url => "https://github.com/NixOS/rfcs/tree/master/rfcs");
my $ua = LWP::UserAgent->new;
my $new_agent = 'Mozilla/5.0 (' . $ua->agent . ')';
$ua->agent($new_agent);

if ($opts{list}) {
 my $data;
 while ( my $token = $p->get_token ) {
    # This prints all text in an HTML doc (i.e., it strips the HTML)
    next unless $token->is_text;
    # GitHub stores this shit in JSON payload on the page itself...
    $data = JSON->new->utf8->decode(encode_utf8($token->as_is)) if ($token->as_is =~ "payload");
 }
 my $rfcs = $data->{payload}{tree}{items};
 foreach my $rfc (@$rfcs) {
  my $rfc = Dumper($rfc->{name});
  say $rfc;
 }
}

if ($opts{rfc}) {
 while ( defined (my $rfc = shift) ) {
  my $url = RFCS . $rfc . ".md";
  say "Fetching: $url";

  my $response = $ua->get($url);
  say $response->decoded_content;
 }
}
