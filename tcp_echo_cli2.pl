#!/usr/bin/env perl
# file: tcp_echo_cli2.pl
# usage: tcp_echo_cli2.pl [host] [port]
# Echo client, TCP version (IO::Socket)

use v5.30.1;
use IO::Socket;

my ($bytes_out, $bytes_in) = (0, 0);

my $host = shift || 'localhost'; 
my $port = shift || 'echo';

my $socket = IO::Socket::INET->new("$host:$port") or die $@;

while (defined (my $msg_out = STDIN->getline)) {
	say $socket $msg_out;
	my $msg_in = <$socket>;
	say $msg_in;

	$bytes_out += length($msg_out);
	$bytes_in += length($msg_in);
}

$socket->close or warn $@;
say STDERR "bytes_sent = $bytes_out, bytes_received = $bytes_in";
