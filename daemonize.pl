#!/usr/bin/env perl
# file: daemonize.pl
#
#	 "And my body is burning like a naked wire
#	 I want to turn on the juice
#	 I want to fall in the fire
#	 I'm gonna drown in the ocean and the bottomless sea
#	 I wanna give you what I'm hoping you'll be giving to me
#	 And when the waves are pounding on the sand tonight
#	 I wanna take your hand
#	 And make it good and make it right
#	 And now the sky is trembling
#	 And the moon is pale
#	 We're on the edge of forever
#	 And we're never gonna fail
#	 No." - Jim Steinman, "Surf's Up"

use v5.10;

use POSIX "setsid";

sleep 2;
say "GO";

sub daemonize {
	chdir("/") or die "can't chdir to /: $!";
	open(STDIN, "<", "/dev/null") or die "can't read: $!";
	# replace this with a file to see results
	open(STDOUT, ">", "/dev/null") or die "can't write: $!";
	defined(my $pid = fork()) or die "can't fork: $!";
	exit if $pid; # non-zero means parent
	(setsid() != -1) or die "Can't start new session: $!";
	open(STDERR, ">&", STDOUT) or die "can't dup stdout: $!";
}

daemonize();

while(1) {
	say "forever";
}
