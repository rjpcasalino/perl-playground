#!/usr/bin/env perl
# file: daytime_cli.pl
# https://tf.nist.gov/tf-cgi/servers.cgi

use 5.30.1;
use Socket;

use constant DEFAULT_ADDR => '127.0.0.1';
use constant PORT	  => 13;
use constant IPPROTO_TCP  => 6;

my $address = shift || DEFAULT_ADDR;
# a BAREWORD was originally used in the call to inet_aton
my $packed_addr = inet_aton($address);
my $destination = sockaddr_in(PORT, $packed_addr);

socket(SOCK, PF_INET, SOCK_STREAM, IPPROTO_TCP) or die "Can't make socket: $!";
connect(SOCK, $destination) or die "Can't connect: $!";

print <SOCK>;
