#!/usr/bin/perl -sw
use strict;
require 5.000_10;

# useage perl -s widefinder.pl -J=2 filename

# based on a version by Eric Wong <normalperson@yhbt.net> - public domain
# originally found at http://normalperson.com/widefinder

# control the number of child processes here
# this should be one less than the number of cores
use vars qw( $J $children %nr );

use constant J => $J || 1;
use constant PROCS => J - 1;

use IPC::Open3;
use Storable qw(nstore_fd fd_retrieve);
use POSIX ':sys_wait_h';

my $rx = qr{GET /ongoing/When/\d{3}x/(\d{4}/\d\d/\d\d/[^ .]+)};

# $SIG{CHLD} = \&reaper;
# $SIG{PIPE} = 'IGNORE';

$|++;

sub child {
    my %tmp;
    while (<>) {
        $_ =~ $rx;
        $tmp{$1}++;
    }
    nstore_fd( \%tmp, \*STDOUT );
    exit 0;
}

sub pre_fork {
    my $children = {};
    for ( 0 .. PROCS ) {
        my $pid = open3( my $in, my $out, my $err, '-' );
        unless ($pid) { child() }
        else {
            $children->{$pid} = { in => $in, out => $out, err => $err };
        }
    }
    return $children;
}

my $children = pre_fork;
open my $data, '<', shift;
while (<$data>) {
    my ($pid) = ( keys %$children )[ $. % J ];
    #warn "Printing to $pid";
    my $child = $children->{$pid};
    print { $child->{in} } $_;
}

for ( keys %$children ) {
    warn "sending end";
    close $children->{$_}->{in};
    my $tmp = fd_retrieve($children->{$_}->{out});
    $nr{$_} += $tmp->{$_} for keys %$tmp;
}

print "$nr{$_}: $_\n"
  for ( ( sort { $nr{$b} <=> $nr{$a} } keys %nr )[ 0 .. 9 ] );
