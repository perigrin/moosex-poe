use strict;
use Test::More no_plan => 1;

{

    package Counter;
    use MooseX::POE;

    has name => (
        isa     => 'Str',
        is      => 'ro',
        default => sub { 'Counter' },
    );

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

    sub on_inc {
        my ($self) = $_[OBJECT];
        ::pass( $self->name . ': Inc ' . $self->count );
        $self->count( $self->count + 1 );
        $self->yield('inc') unless $self->count > 3;
    }

    sub STOP {
        ::pass('Stopping');
    }

    no MooseX::POE;
#    __PACKAGE__->meta->make_immutable;
}

my @objs = map { Counter->new( name => 'Counter ' . $_ ) } ( 1 .. 30 );
POE::Kernel->run();
