#!/usr/bin/env perl
# file: time_of_day_tcp2.pl

use v5.10;
use IO::Socket qw(:DEFAULT :crlf);

my $host = shift || 'localhost';
$/ = CRLF;

my $socket = IO::Socket::INET->new("$host:daytime") or die "Can't connect to daytime server @ host: $!";

chomp(my $time = $socket->getline);
say $time;
