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

class App with Rollo {
    use MooseX::POE;

    method START { 
        ::pass('START');
        $self->foo();
        $self->yield('next');
    }
    
    event next => sub {
        my ($self) = $_[OBJECT];
        ::pass('next');
        $self->yield("yarr");
    };
    
    method STOP { ::pass('STOP') }
}

my $obj = App->new;

does_ok($obj, 'Rollo');
$DB::single = 1;
POE::Kernel->run;
