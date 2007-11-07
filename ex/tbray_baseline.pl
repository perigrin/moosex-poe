#!/usr/bin/env perl -l

#
# http://www.tbray.org/ongoing/When/200x/2007/09/20/Wide-Finder
#

#
# Rather than Erlang (as was in here before) this is more based on the
# Scala version of this code at
# http://www.martin-probst.com/2007/09/24/wide-finder-in-scala/
#

#
# requires the data at http://www.tbray.org/tmp/o10k.ap
#
use strict;
use warnings;
use IO::File;

$|++;

die 'no file' unless -e 'ex/tbray.data.big';
my $file = IO::File->new( 'ex/tbray.data.big', 'r' ) or die $!;
my $rx = qr|GET /ongoing/When/\d\d\dx/(\d\d\d\d/\d\d/\d\d/[^ .]+)|o;
my %count;
while (<$file>) {
    next unless $_ =~ $rx;
    $count{$1}++;
}
print "$count{$_}: $_"
  for ( sort { $count{$b} <=> $count{$a} } keys %count )[ 0 .. 10 ];
