#!/usr/bin/env perl
# file: get_url.pl

use v5.30.1;
use LWP;

my $url = shift;

my $agent = LWP::UserAgent->new();
my $request = HTTP::Request->new(GET => $url);

my $response = $agent->request($request);

$response->is_success or die "$url: ", $response->message, "\n";

say $response->content;
