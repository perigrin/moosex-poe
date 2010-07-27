#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use POE;

my @reason;
my @retval;

{

    package Foo;
    use MooseX::POE;

    sub START {
        ::ok('Foo Start');
        return 'create';
    }

    sub STOP {
        ::ok('Foo Stop');
        return 'lose';
    }
}

{

    package ImmutableFoo;
    use MooseX::POE;

    sub START {
        ::ok('Immutale Foo Start');
        return 'create';
    }

    sub STOP {
        ::ok('Immutale Foo Stop');
        return 'lose';
    }

    __PACKAGE__->meta->make_immutable( inline_constructor => 0 );
}

use Data::Dumper;
POE::Session->create(
    inline_states => {
        _start => sub {
            Foo->new();
        },
        _child => sub {
            diag Dumper [ @_[ ARG0, ARG2 ] ];
            push( @reason, $_[ARG0] );
            push( @retval, $_[ARG2] );
        },
    }
);

$poe_kernel->run;

is( scalar(@reason), 2, "called two times" );

is_deeply( $reason[0], 'create', "CHILD create was called" );
is_deeply( $reason[1], 'lose',   "CHILD lose was called" );
is_deeply( $retval[0], 'create', "START return value is correct" );
is_deeply( $retval[1], 'lose',   "STOP return value is correct" );

@reason = ();
@retval = ();

POE::Session->create(
    inline_states => {
        _start => sub {
            ImmutableFoo->new();
        },
        _child => sub {
            push( @reason, $_[ARG0] );
            push( @retval, $_[ARG2] );
        },
    }
);

$poe_kernel->run;

is( scalar(@reason), 2, "called two times" );

is_deeply( $reason[0], 'create', "CHILD create was called" );
is_deeply( $reason[1], 'lose',   "CHILD lose was called" );
is_deeply( $retval[0], 'create', "START return value is correct" );
is_deeply( $retval[1], 'lose',   "STOP return value is correct" );

done_testing;
