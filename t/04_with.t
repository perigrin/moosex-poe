#!/usr/bin/perl -w

use strict;
use Test::More tests => 4;

{
    package Rollo;
    use Moose::Role;
    
    sub foo { ::pass('foo!')}
}

{
    package App;
    use MooseX::POE;
    
    with qw(Rollo);
    
    sub START { 
        my ($self) = $_[OBJECT];
        ::pass('START');
        $self->foo();
        $self->yield('next');
    }
    
    event next => sub { ::pass('next') };
    
    sub STOP { ::pass('STOP') }
}

App->new;
POE::Kernel->run;