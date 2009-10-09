#!/usr/bin/env perl
use strict;
use Test::More tests => 6;

{

    package Base;
    use MooseX::POE;

    sub START {
        ::pass('Base Start');
    }

    event hello => sub {
        ::pass('hello');
        $_[KERNEL]->yield('goodbye');
    };
}
{

    package Extended;
    use MooseX::POE;

    extends 'Base';

    sub START {
        ::pass('Extended after Start');
        $_[KERNEL]->yield( 'hello' => 'world' );
    }

    before 'hello' => sub {
        ::is( $_[ARG0], 'world', 'before saw world' );
    };

    after 'hello' => sub {
        ::is( $_[ARG0], 'world', 'after saw world' );
    };

    event goodbye => sub {
        ::pass('goodbye');
    };

}

my $foo = Extended->new();
POE::Kernel->run();
