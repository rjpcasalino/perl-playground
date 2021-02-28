#!/usr/bin/env perl
# file: daemonize.pl
#

use v5.32;

use POSIX "setsid";

my @lyric = qw(
And my body is burning like a naked wire
I want to turn on the juice
I want to fall in the fire
I'm gonna drown in the ocean and the bottomless sea
I wanna give you what I'm hoping you'll be giving to me
And when the waves are pounding on the sand tonight
I wanna take your hand
And make it good and make it right
And now the sky is trembling
And the moon is pale
We're on the edge of forever
And we're never gonna fail
No.
- Jim Steinman, "Surf's Up"
);

sub daemonize {
	chdir("/") or die "can't chdir to /: $!";
	# in case of zombies...
	# see perldoc -f open
	# go deeper with 
	# perldoc perlopentut
	open(STDIN, "<", "/dev/null") or die "can't read: $!";
	close STDOUT;
	open(STDOUT, ">", "/dev/null") or die "can't write: $!";
	# fork returns: 
	# non-zero if parent process; 0 if child; undef if error
	defined(my $pid = fork()) or die "can't fork: $!";
	exit if $pid;
	# see setsid(2)
	(setsid() != -1) or die "Can't start new session: $!";
	#  >&: the string is
	#  interpreted as the name of a filehandle 
	#  (or file descriptor, if numeric) to be duped - dup(2)
	open(STDOUT, ">&", STDERR) or die "can't dup STDOUT: $!";
	select STDERR; $| = 1;  # make unbuffered
	select STDOUT; $| = 1;  # make unbuffered
}

daemonize();

while(1) {
	foreach (@lyric) {
		say STDOUT "$_";
		sleep 1;
	}
}
