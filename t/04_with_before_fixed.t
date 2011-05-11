use strict; use warnings;

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

    sub START {
        ::pass('START');
        $_[KERNEL]->yield('foo');
    }

    event foo => sub {
        ::pass('foo');
        print "BAR\n";
    };

    # notice how it passes if we place it here
    # while in 04_with_before.t it fails... :(
    with 'Rollo';
}

App->new;
POE::Kernel->run;
