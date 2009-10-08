use Test::More skip_all => 'Moose upstream needs to sort out immutability';
use Test::More tests => 2;

{

    package mxpoe;

    use MooseX::POE;
    use Test::More;

    sub START {
        my ( $kernel, $self ) = @_[ KERNEL, OBJECT ];
        diag "Starting .... \n";
        $kernel->yield('counter_event');
        return;
    }

    event 'counter_event' => sub {
        my ( $kernel, $self ) = @_[ KERNEL, OBJECT ];
        pass('Got a counter event');
        return;
    };

    no MooseX::POE;

    __PACKAGE__->meta->make_immutable;
}

{

    package mxpoet;

    use MooseX::POE;
    use Test::More;

    extends 'mxpoe';

    sub START {
        my ( $kernel, $self ) = @_[ KERNEL, OBJECT ];
        diag "Starting EXTENSION .... \n";
        $kernel->yield('counter_event');
        return;
    }

    no MooseX::POE;
}

package main;
use strict;
use warnings;
use POE;

my $mxpoe = mxpoet->new();

$poe_kernel->run();
exit 0;
