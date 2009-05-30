use strict;
use Test::More skip_all => 'Moose upstream needs to sort out composition';

use Test::More tests => 2;

{
    package Rollo;
    use MooseX::POE::Role;

    event foo => sub {
        ::fail('not overridden');
    };
}

{
    package Foo;
    use MooseX::POE;
    with 'Rollo';

    sub START {
        ::pass('START');
        $_[KERNEL]->yield('foo');
    }

    event foo => sub {
        ::pass('overridden foo');
    };
}

Foo->new;
POE::Kernel->run;
