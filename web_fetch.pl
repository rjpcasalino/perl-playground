#!/usr/bin/env perl
# file: web_fetch.pl

use v5.30.1;
use IO::Socket qw(:DEFAULT :crlf);
$/ = CRLF . CRLF;
my $data;

my $url = shift or die "Usage: web_fetch.pl <URL>\n";

my ($host, $path) = $url=~m!^http[s]?://([^/]+)(/[^\#]*)! or die "Invalid URL\n";

my $socket = IO::Socket::INET->new(PeerAddr => $host, PeerPort => 80)
	or die "Can't connect: $!";

print $socket "GET $path HTTP/1.0",CRLF,CRLF;

my $header = <$socket>; # read the header
$header =~ s/$CRLF/\n/g;
say $header;

say $data while read($socket,$data,1024) > 0;
