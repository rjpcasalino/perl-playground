#!/usr/env perl
# Derived from code by Nathan Torkington
# also - Jon Orwant, Jarkko Hietaniemi & John Macdonald
# note: assumes the file contains one word per line, sorted lexicographically
use v5.10;
use strict;
use integer;

my ($word, $file) = @ARGV;
open (FILE, $file) or die "Can't open $file: $!";
my $position = binary_search(\*FILE, $word);

if (defined $position) { say "$word occurs at position $position" }
else                   { say "$word does not occur in $file" }

sub binary_search {
        my ( $file, $word ) = @_;
        my ( $high, $low, $mid, $mid2, $line );
        $low = 0;
        $high = (stat($file))[7]; # Might not be the start of line.
        $word =~ s/\W//g;
        $word =~ lc($word);

        while ($high != $low) {
                $mid = ($high+$low)/2;
                seek($file, $mid, 0) || die "Couldn't seek: $!\n";

                $line = <$file>;
                $mid2 = tell($file);

                if ($mid2 < $high) {
                        $mid = $mid2;
                        $line = <$file>;
                } else {
                        seek($file, $low, 0) || die "Couldn't seek: $!\n";
                        while (defined($line = <$file>)) {
                                last if compare($line, $word) >= 0;
                                $low = tell($file);
                        }
                        last;
                }
                if (compare($line,$word) < 0) { $low = $mid }
                else                         { $high = $mid }
        }
        return if compare($line, $word);
        return $low;
}

sub compare {
        my ($word1,$word2) = @_;
        $word1 =~ s/\W//g; $word = lc($word1);
        return $word1 cmp $word2;
}
