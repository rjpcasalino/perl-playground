#!/usr/bin/env perl
# file: tcp_echo_serv2.pl

use v5.30.1;
use IO::Socket qw(:DEFAULT :crlf);
use constant MY_ECHO_PORT => 2007;
# removing input record separator
# makes this actually echo back?
# why? ArrrraaagAHHHHHH!
# $/ = CRLF;

my ($bytes_out, $bytes_in) = (0,0);

my $quit = 0;
$SIG{INT} = sub { $quit++ };

my $port = shift || MY_ECHO_PORT;

my $sock = IO::Socket::INET->new( Listen => 20,
				  LocalPort => $port,
			  	  Timeout => 60*60,
				  Proto => 'tcp',
			  	  Reuse => 1)
				  or die "Can't create listening socket: $!";

warn "waiting for incoming connections on $port...\n";
while (!$quit) {
	next unless my $session = $sock->accept;

	my $peer = gethostbyaddr($session->peeraddr, AF_INET) || 
	$session->peerhost;
	my $port = $session->peerport;
	warn "Connection from [$peer,$port]\n";

	while (<$session>) {
		$bytes_in += length($_);
		chomp;
		my $msg_out = (scalar reverse $_) . CRLF;
		print $session $msg_out;
		$bytes_out += length($msg_out);
	}
	warn "Connection from [$peer, $port] done\n";
	close $session;
}

print STDERR "bytes_sent = $bytes_out, bytes_received = $bytes_in\n";
close $sock;

