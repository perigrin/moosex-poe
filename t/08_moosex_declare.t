#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Test::Moose;

BEGIN { 
  eval "use MooseX::Declare;";
  plan skip_all => "MooseX::Declare not installed; skipping" if $@;
}

plan tests => 6;


role Rollo {
    use MooseX::POE::Role qw(event);
    
    sub foo { ::pass('foo!')}

    event yarr => sub { ::pass("yarr!") }
}

does_ok(Rollo->meta, "MooseX::POE::Meta::Role");

class App with Rollo {
    use MooseX::POE qw(event);

    sub START { 
        my ($self) = $_[OBJECT];
        ::pass('START');
        $self->foo();
        $self->yield('next');
    }
    
    event next => sub {
        my ($self) = $_[OBJECT];
        ::pass('next');
        $self->yield("yarr");
    };
    
    sub STOP { ::pass('STOP') }
}

my $obj = App->new;

POE::Kernel->run;
