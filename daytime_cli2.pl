#!/usr/bin/env perl
# file: daytime_cli2.pl

use 5.30.1;
use Socket;

use constant DEFAULT_ADDR => '127.0.0.1';

my $packed_addr = gethostbyname(shift || DEFAULT_ADDR) or die "Can't look up host: $!";
my $protocol = getprotobyname('tcp');
my $port = getservbyname('daytime', 'tcp') or die "Can't look up port: $!";
my $destination = sockaddr_in($port, $packed_addr);

socket(SOCK, PF_INET, SOCK_STREAM, $protocol) or die "Can't make socket: $!";
connect(SOCK, $destination) or die "Can't connect: $!";

say <SOCK>;
