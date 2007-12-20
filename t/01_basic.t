use strict;
use Test::More no_plan => 1;

{

    package Counter;
    use MooseX::POE;

    has count => (
        isa     => 'Int',
        is      => 'rw',
        lazy    => 1,
        default => sub { 0 },
    );

    sub START {
        my ($self) = $_[OBJECT];
        ::pass('Starting ');
        $self->yield('inc');
    }

    event inc => sub {
        my ($self) = $_[OBJECT];
        ::pass( $self . ':' . $self->count );
        $self->count( $self->count + 1 );
        return if 3 < $self->count;
        $self->yield('inc');
    };

    sub STOP {
        ::pass('Stopping');
    }

    no MooseX::POE;
}

my @objs = map { Counter->new } ( 1 .. 30 );
POE::Kernel->run();