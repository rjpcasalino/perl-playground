#!/usr/bin/env perl
# markov.pl: markov chain text generator with configurable n-gram prefixes
#
# Usage: perl markov.pl [-n prefix_size] [-w max_words] [file ...]
#   -n  prefix size (number of words in chain state, default: 2)
#   -w  maximum words to generate (default: 100)
#
# Reads text from files or STDIN and generates pseudo-random text
# using a Markov chain built from the input corpus.

use v5.10;
use strict;
use warnings;
use Getopt::Long;

my $prefix_size = 2;
my $max_words   = 100;
my $NONWORD     = "\n";

GetOptions(
        'n=i' => \$prefix_size,
        'w=i' => \$max_words,
) or die "Usage: $0 [-n prefix_size] [-w max_words] [file ...]\n";

die "Prefix size must be at least 1\n" if $prefix_size < 1;

# Build the state table: key is a join of the prefix words,
# value is an array of possible next words.
my %statetab;
my @prefix = ($NONWORD) x $prefix_size;

while (<>) {
        foreach (split) {
                my $key = join($;, @prefix);
                push @{$statetab{$key}}, $_;
                shift @prefix;
                push @prefix, $_;
        }
}

# Mark the end of input
my $key = join($;, @prefix);
push @{$statetab{$key}}, $NONWORD;

# Generate output
@prefix = ($NONWORD) x $prefix_size;
for my $i (0 .. $max_words - 1) {
        my $key = join($;, @prefix);
        my $suf = $statetab{$key};
        last unless $suf;
        my $r = int(rand @$suf);
        my $t = $suf->[$r];
        last if $t eq $NONWORD;
        print "$t ";
        shift @prefix;
        push @prefix, $t;
}
print "\n";
