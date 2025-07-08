# markov.pl: markov chain alforithm for 2-word prefixes

$MAXGEN = 100;
$NONWORD = "\n";
$w1 = $w2 = $NONWORD;

while (<>) {
        foreach (split) {
                push(@{$statetab{$w1}{$w2}}, $_);
                ($w1, $w2) = ($w2, $_); #multiple assignment
        }
}

push(@{$statetab{$w1}{$w2}}, $NONWORD); # add tail

$w1 = $w2 = $NONWORD;
for ($i = 0; $i < $MAXGEN; $i++) {
        $suf = $statetab{$w1}{$w2}; # arrary reference
        $r = int(rand @$suf);
        exit if (($t = $suf->[$r]) eq $NONWORD);
        print "$t ";
        ($w1, $w2) = ($w2, $t); # advance chain
}
