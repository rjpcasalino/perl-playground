#!/usr/bin/env perl
# file: sighup.pl
# surf's up and so am I

use v5.10;

use POSIX();
use FindBin();
use File::Basename();
use File::Spec::Functions qw(catfile);

# autoflush
$| = 1;

my $script = File::Basename::basename($0);
my $SELF = catfile($FindBin::Bin, $script);

# POSIX unmasks the sigprocmask properly
my $sigset = POSIX::SigSet->new();
my $action = POSIX::SigAction->new('sigHUP_handler',
                             $sigset,
                             &POSIX::SA_NODEFER);
POSIX::sigaction(&POSIX::SIGHUP, $action);

sub sigHUP_handler {
	say "got SIGHUP";
	say "Surf's up and so am I!";
	exec($SELF, @ARGV) or die "$0: couldn't restart: $!";
};

code();

sub code {
	say "PID: $$";
	say "ARGV: @ARGV";
	my $count = 0;
	while (1) {
		sleep 2;
		print ++$count, "\n";
	}
}
