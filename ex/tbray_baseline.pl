#!/usr/bin/env perl -l

#
# http://www.tbray.org/ongoing/When/200x/2007/09/20/Wide-Finder
#

#
# requires the data at http://www.tbray.org/tmp/o10k.ap
#

my $rx = qr|GET /ongoing/When/\d\d\dx/(\d\d\d\d/\d\d/\d\d/[^ .]+)|o;
my %count;
while (<>) {
    next unless $_ =~ $rx;
    $count{$1}++;
}
print "$count{$_}: $_"
  for ( sort { $count{$b} <=> $count{$a} } keys %count )[ 0 .. 9 ];
