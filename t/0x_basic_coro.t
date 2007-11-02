use strict;
use Test::More tests => 186;
use Coro;
{

    package Counter;
    use MooseX::Coro;

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
        my ($self) = @_;
        ::pass( 'Starting ' . $self->name );
        $self->yield('inc');
        $self->yield('STOP');
    }

    event inc => sub {
        my ($self) = @_;
        ::pass( $self->name . ': Inc ' . $self->count );
        $self->count( $self->count + 1 );
        $self->yield('inc') unless $self->count > 3;
    };

    sub STOP {
        ::pass('Stopping');
    }

    no MooseX::Coro;

    __PACKAGE__->meta->make_immutable;
}

my @objs = map { Counter->new( name => 'Counter ' . $_ ) } ( 0 .. 30 );

