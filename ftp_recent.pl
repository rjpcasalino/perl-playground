#!/usr/bin/env perl
# file: ftp_recent.pl

use v5.30.1;

use Net::FTP;

use constant HOST => 'ftp.perl.org';
use constant DIR => '/pub/CPAN';
use constant FILE => 'RECENT';

my $ftp = Net::FTP->new(HOST) or die "Couldn't connect:$@\n";
$ftp->login('anonymous');
$ftp->cwd(DIR);
$ftp->get(FILE);
$ftp->quit;
warn "File retrived successfully.\n";
