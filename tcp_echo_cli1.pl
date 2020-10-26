#!/usr/bin/env perl
# file: tcp_echo_cli1.pl

use 5.30.1; # only because this comes with nixOS
use Socket;
use IO::Handle;

my ($bytes_out, $bytes_in) = (0, 0); # a list 

my $host = shift || 'localhost'; 
my $port = shift || getservbyname('echo', 'tcp');

my $protocol = getprotobyname('tcp');
$host = inet_aton($host) or die "host: unknown host";

socket(SOCK, AF_INET, SOCK_STREAM, $protocol) or die "socket() failed: $!";
my $dest_addr = sockaddr_in($port, $host);
connect(SOCK, $dest_addr) or die "connect() failed: $!";

SOCK->autoflush(1);

while (my $msg_out = <>) {
	say SOCK $msg_out;
	my $msg_in = <SOCK>;
	say $msg_in;

	$bytes_out += length($msg_out);
	$bytes_in  += length($msg_in);
}

close SOCK;
say STDERR "bytes_sent = $bytes_out, bytes_received = $bytes_in";
