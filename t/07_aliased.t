#!/usr/bin/env perl
use strict; use warnings;

use Test::More tests => 6;
use Test::Fatal;

use POE;

my @log;

{

    package Foo;
    use MooseX::POE;

    with qw(MooseX::POE::Aliased);

    event foo => sub {
        push @log, [ @_[ ARG0 .. $#_ ] ];
    };
}
{

    package ImmutableFoo;
    use MooseX::POE;

    with qw(MooseX::POE::Aliased);

    event foo => sub {
        push @log, [ @_[ ARG0 .. $#_ ] ];
    };

    __PACKAGE__->meta->make_immutable( inline_constructor => 0 );
}

my $foo = Foo->new( alias => "blah" );

POE::Session->create(
    inline_states => {
        _start => sub {
            $_[KERNEL]->yield("blah");
        },
        blah => sub {
            $_[KERNEL]->post( blah => foo => "this" );
            $foo->alias("bar");
            $_[KERNEL]->post( bar => foo => "that" );
        },
    }
);

POE::Kernel->run;

is( scalar(@log), 2, "two events" );

is_deeply( $log[0], ["this"], "first event under alias 'blah'" );
is_deeply( $log[1], ["that"], "second event under alias 'bar'" );

@log = ();
$foo = ImmutableFoo->new( alias => "blah" );

POE::Session->create(
    inline_states => {
        _start => sub {
            $_[KERNEL]->yield("blah");
        },
        blah => sub {
            $_[KERNEL]->post( blah => foo => "this" );
            $foo->alias("bar");
            $_[KERNEL]->post( bar => foo => "that" );
        },
    }
);

POE::Kernel->run;

is( scalar(@log), 2, "two events" );

is_deeply( $log[0], ["this"], "first event under alias 'blah'" );
is_deeply( $log[1], ["that"], "second event under alias 'bar'" );

