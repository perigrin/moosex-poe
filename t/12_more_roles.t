#!/usr/bin/perl
use strict; use warnings;
use Test::More tests => 1;
{
    package Getty;
    use Moose::Role;
}

{
    package Pants;
    use MooseX::POE::Role;

    event 'wear' => sub {
        ::pass("I AM BEING WORN!");
    };
}

{
    package Clocks;
    use MooseX::POE;
    with 'Pants', 'Getty';

    sub bork {
        my ($self) = @_;
	::pass('bork');
        $self->yield('wear');
    }
}



my $c = Clocks->new;
$c->bork;
POE::Kernel->run;
