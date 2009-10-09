#!/usr/bin/env perl
use strict;
use Test::More tests => 4;

{

    package Base;
    use MooseX::POE;

    sub START {
        ::pass('Base Start');
        $_[OBJECT]->yield( 'foo' => 'bar' );
    }

    event foo => sub {
        ::pass('foo');
    };

    before 'foo' => sub {
        ::is( $_[ARG0], 'bar', 'before saw bar' );
    };

    after 'foo' => sub {
        ::is( $_[ARG0], 'bar', 'after saw bar' );
    };

}
my $obj = Base->new();
POE::Kernel->run();
