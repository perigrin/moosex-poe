use strict; use warnings;
use Test::More skip_all => 'Moose upstream needs to sort out composition';

use Test::More tests => 3;

{

    package Rollo;
    use MooseX::POE::Role;

    before foo => sub {
        ::pass('before foo');
    };
}

{

    package App;
    use MooseX::POE;
    with 'Rollo';

    sub START {
        ::pass('START');
        $_[KERNEL]->yield('foo');
    }

    event foo => sub {
        ::pass('foo');
        print "BAR\n";
    };
}

App->new;
POE::Kernel->run;
