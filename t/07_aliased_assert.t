#!/usr/bin/env perl
use strict; use warnings;

use Test::More tests => 8;
use Test::Fatal;

{
    sub POE::Kernel::ASSERT_DEFAULT () { 1 }

    package Aliased;
    use MooseX::POE;

    with qw/MooseX::POE::Aliased/;

    has foo => ( is => 'rw', isa => 'Str', default => '' );
    has bar => ( is => 'rw', isa => 'Int', default => 0 );

    event 'ping' => sub {
        my $self = shift;
        ::pass( "received ping" );

        # tell the master to send us another event!
        $self->alias( 'foobar' );
        $poe_kernel->post( 'master', 'test_changed' );
    };

    event 'test_changed' => sub {
        my $self = shift;
        ::pass( "received test_changed" );

        # send an event to the new alias
        $poe_kernel->post( 'foobar', 'ping2' );

        ::is( $poe_kernel->alias_resolve( 'tester' ), undef,
            'Old alias is really gone' );
    };

    event 'ping2' => sub {
        my $self = shift;
        ::pass( "received ping2" );

        # remove our alias
        $self->alias( undef );
    };

    sub STARTALL {
        my $self = shift;

        # test sending an event to the other aliased session
        return unless defined $self->alias and $self->alias eq 'master';
        $poe_kernel->post( 'tester', 'ping' );
    }

    no MooseX::POE;
}

is( exception { Aliased->new( alias => 'tester' ) },
    undef, 'can create Aliased with ASSERT_DEFAULT' );

is( exception { Aliased->new( alias => 'master' ) },
    undef, 'can create Aliased with ASSERT_DEFAULT' );

is( exception { Aliased->new( alias => undef ) },
    undef, 'can create no Aliased with ASSERT_DEFAULT' );

is( exception {POE::Kernel->run },
    undef, 'The entire thing works :)' );

