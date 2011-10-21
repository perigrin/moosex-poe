#!/usr/bin/env perl
use strict; use warnings;
use Test::More tests => 1;

{
    package Foo;
    use MooseX::POE;

    package Bar;
    use Moose;
    has a => ( is => 'ro' );
}

ok(!exists Bar->new( a => 1 )->{session_id}, 'no session_id');
