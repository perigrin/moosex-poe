package ooseX::POE;
use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:PERIGRIN';

BEGIN {
    my $package;
    sub import { $package = $_[1] || 'Class' }
    use Filter::Simple sub { s/^/package $package;\nuse MooseX::POE;\n/; }
}

1;