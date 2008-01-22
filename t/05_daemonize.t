#!/usr/bin/perl -w
use strict;
use Test::More;
eval "use MooseX::Daemonize";
plan skip_all => "MooseX::Daemonize not installed; skipping" if $@;

plan tests => 3;

{
    package App;
    use MooseX::POE;
    
    with qw(MooseX::Daemonize);
    
    sub START { 
        my ($self) = $_[OBJECT];
        ::pass('START');
        $self->yield('next');
    }
    
    event next => sub { ::pass('next') };
    
    sub STOP { ::pass('STOP') }
}

App->new;
POE::Kernel->run;
