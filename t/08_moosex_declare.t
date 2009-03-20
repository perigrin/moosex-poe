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
    use MooseX::POE::Role;
    
    sub foo { ::pass('foo!')}

    event yarr => sub { ::pass("yarr!") }
}

does_ok(Rollo->meta, "MooseX::POE::Meta::Role");

class App with Rollo is mutable {
    use MooseX::POE;

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
