#!/usr/bin/env perl
use strict;
use warnings;

# mplay.pl --- browse media on a media server aka bufflehead, stream to local mpv
#
# Works with ssh password auth: the script opens one ssh
# ControlMaster connection (you type the password ONCE) and reuses
# it for the listing and every subsequent stream. The master
# persists 10 minutes past the last use, then closes itself.
#
# Set BUFFLEHEAD_HOST env var if your ssh alias is different.
#
# Caveats:
#  - mpv can't seek backward past its cache when reading from a
#    pipe. For real seeking, mount with sshfs and open with mpv,
#    or play through the DLNA server in a DLNA client.
#  - filenames with embedded TAB or NEWLINE characters won't be
#    parsed correctly off the find output. Everything else (spaces,
#    parens, brackets, apostrophes, ampersands, $, etc.) is handled
#    by quoting the path twice -- once for the remote shell, once
#    for the local shell -- since ssh strips one layer of quoting
#    when it joins its args to send to the remote.

my $remote     = $ENV{BUFFLEHEAD_HOST} || 'bufflehead';
my @media_dirs = qw(/mnt/hd1 /mnt/hd2 /mnt/hd3 /mnt/hd4);
my $hit_cap    = 500;   # refuse to navigate more than this many hits

my %media_types = (
    video => [qw(mkv mp4 avi mov m4v webm wmv flv mpg mpeg ts iso)],
    audio => [qw(mp3 flac ogg wav m4a aac opus wma)],
);

# --- ssh connection-sharing setup ----------------------------------
my $ctl_socket = "/tmp/media-play-$$.sock";
my $ssh = "ssh"
        . " -o ControlMaster=auto"
        . " -o ControlPath=$ctl_socket"
        . " -o ControlPersist=600";

# --- terminal raw-mode helpers -------------------------------------
# stty -g prints the current settings in a re-loadable format. We
# save it ONCE on first raw_on and restore it on raw_off; safe to
# call either repeatedly.
my $saved_stty;
sub raw_on {
    unless (defined $saved_stty) {
        chomp($saved_stty = `stty -g </dev/tty`);
    }
    system("stty -echo -icanon min 1 time 0 </dev/tty");
    print "\e[?25l";    # hide cursor
}
sub raw_off {
    print "\e[?25h";    # show cursor
    system("stty $saved_stty </dev/tty") if defined $saved_stty;
}

$SIG{INT} = sub { raw_off(); exit 130 };
END {
    raw_off();
    if (defined $ctl_socket && -e $ctl_socket) {
        system("ssh -O exit -o ControlPath=$ctl_socket $remote "
             . ">/dev/null 2>&1");
    }
}

# --- helpers -------------------------------------------------------
sub shq {
    my $s = shift;
    $s =~ s/'/'\\''/g;
    return "'$s'";
}

sub human {
    my $n = shift;
    my @u = qw(B K M G T);
    my $i = 0;
    while ($n >= 1024 && $i < $#u) { $n /= 1024; $i++ }
    return sprintf "%.1f%s", $n, $u[$i];
}

# Read one key event, returning a symbolic name or a literal byte.
# Handles arrow keys and a few common CSI sequences.
sub read_key {
    my $b;
    return 'eof' unless sysread(STDIN, $b, 1);
    return 'enter' if $b eq "\r" || $b eq "\n";
    return $b unless $b eq "\e";

    # ESC: either bare Esc or the start of a CSI sequence
    my $rin = '';
    vec($rin, fileno(STDIN), 1) = 1;
    return 'esc' unless select($rin, undef, undef, 0.05);
    sysread(STDIN, my $b2, 1);
    return 'esc' unless $b2 eq '[';

    sysread(STDIN, my $b3, 1);
    if ($b3 =~ /[A-DHF]/) {
        return { A=>'up', B=>'down', C=>'right', D=>'left',
                 H=>'home', F=>'end' }->{$b3};
    }
    # multi-byte: ESC [ 5 ~  =  pgup, ESC [ 6 ~  =  pgdn, etc.
    my $seq = $b3;
    while (length($seq) < 6) {
        select($rin, undef, undef, 0.05) or last;
        sysread(STDIN, my $bn, 1);
        $seq .= $bn;
        last if $bn !~ /[0-9;]/;
    }
    return 'pgup' if $seq eq '5~';
    return 'pgdn' if $seq eq '6~';
    return 'home' if $seq eq '1~' || $seq eq '7~';
    return 'end'  if $seq eq '4~' || $seq eq '8~';
    return 'esc';
}

# Draw the menu. Returns the window size in rows.
sub draw {
    my ($hits, $cursor, $top, $query, $rows) = @_;
    my $win = $rows - 4;
    $win = 1 if $win < 1;

    print "\e[H\e[J";    # home + clear to end of screen
    printf "search %s -- %d hit%s\n",
           ($query eq '' ? '(all)' : "\"$query\""),
           scalar @$hits, (@$hits == 1 ? '' : 's');
    print "j/k move  Enter play  q back  Ctrl-C quit\n\n";

    my $last = $top + $win - 1;
    $last = $#$hits if $last > $#$hits;
    for my $i ($top .. $last) {
        my ($size, $path) = @{ $hits->[$i] };
        my $on = $i == $cursor;
        print "\e[7m" if $on;     # reverse video on
        printf "%s [%3d] %8s  %s",
               ($on ? '>' : ' '), $i + 1, human($size), $path;
        print "\e[0m" if $on;     # reset
        print "\n";
    }
    return $win;
}

# --- pick category -------------------------------------------------
print "category? [v]ideo / [a]udio / [q]uit: ";
my $reply = <STDIN>;
exit 0 unless defined $reply;
my $cat;
if    ($reply =~ /^v/i) { $cat = 'video' }
elsif ($reply =~ /^a/i) { $cat = 'audio' }
else                    { exit 0 }

# --- fetch file list -----------------------------------------------
print "fetching $cat list from $remote ...\n";
print "(ssh will ask for your password the first time only)\n\n";

my $find_exprs = join ' -o ',
                 map { "-iname \\*.$_" } @{ $media_types{$cat} };
my $dirs       = join ' ', @media_dirs;
my $remote_cmd = "find $dirs -type f \\( $find_exprs \\) "
               . "-printf '%s\\t%p\\n'";

my @files;
open my $fh, '-|', "$ssh $remote \"$remote_cmd\" 2>/dev/null"
    or die "ssh: $!";
while (<$fh>) {
    chomp;
    my ($size, $path) = split /\t/, $_, 2;
    push @files, [ $size, $path ] if defined $path;
}
close $fh;
printf "%d files found.\n\n", scalar @files;
exit 0 unless @files;

# --- search / navigate / play loop ---------------------------------
while (1) {
    print "search (empty=all, q=quit): ";
    my $q = <STDIN>;
    last unless defined $q;
    chomp $q;
    last if $q eq 'q';

    my $needle = lc $q;
    my @hits   = sort { $a->[1] cmp $b->[1] }
                 grep { index(lc $_->[1], $needle) >= 0 } @files;

    unless (@hits) { print "no matches.\n\n"; next; }
    if (@hits > $hit_cap) {
        printf "%d hits is too many to navigate; refine to under %d.\n\n",
               scalar @hits, $hit_cap;
        next;
    }

    # terminal size for paging
    my ($rows) = split ' ', `stty size </dev/tty`;
    $rows ||= 24;

    my $cursor = 0;
    my $top    = 0;

    raw_on();
    my $win = draw(\@hits, $cursor, $top, $q, $rows);

    NAV: while (1) {
        my $key = read_key();

        if    ($key eq 'down' || $key eq 'j') { $cursor++ }
        elsif ($key eq 'up'   || $key eq 'k') { $cursor-- }
        elsif ($key eq 'pgdn' || $key eq ' ') { $cursor += $win }
        elsif ($key eq 'pgup')                { $cursor -= $win }
        elsif ($key eq 'home' || $key eq 'g') { $cursor = 0 }
        elsif ($key eq 'end'  || $key eq 'G') { $cursor = $#hits }
        elsif ($key eq 'enter') {
            raw_off();
            my $path = $hits[$cursor][1];
            my $arg  = shq(shq($path));
            print "\nstreaming: $path\n";
            system("$ssh $remote cat $arg "
                 . "| mpv --cache=yes --force-window=immediate -");
            print "\n";
            raw_on();
        }
        elsif ($key eq 'q'   || $key eq 'esc' || $key eq 'eof') {
            last NAV;
        }
        elsif ($key eq "\x03") {    # Ctrl-C
            raw_off();
            exit 130;
        }

        # clamp cursor and scroll window
        $cursor = 0       if $cursor < 0;
        $cursor = $#hits  if $cursor > $#hits;
        $top = $cursor              if $cursor < $top;
        $top = $cursor - $win + 1   if $cursor >= $top + $win;
        $top = 0 if $top < 0;

        $win = draw(\@hits, $cursor, $top, $q, $rows);
    }
    raw_off();
    print "\n";
}

