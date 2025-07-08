#!/usr/bin/env perl
# file: get_url.pl

use v5.30.1;
use LWP;

use HTML::TokeParser::Simple;
my $url = shift;

# Fetch nixos.org and print all hrefs.
my $p = HTML::TokeParser::Simple->new(url => $url);

while ( my $token = $p->get_token ) {
    # This prints all text in an HTML doc (i.e., it strips the HTML)
    next unless $token->is_text;
    say $token->as_is;
}


my $agent = LWP::UserAgent->new();
$agent->agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:68.0) Gecko/20100101 Firefox/68.0");
my $request = HTTP::Request->new(GET => $url);

my $response = $agent->request($request);

$response->is_success or die "$url: ", $response->message, "\n";

say $response->content;
