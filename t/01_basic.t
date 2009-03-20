use strict;
use Test::More;
my $mem_cycle = eval { require Test::Memory::Cycle } || 0;
my $num_objs = 10;
plan tests => 10*$num_objs + $mem_cycle *2;

{

    package Counter;
    use MooseX::POE;

    has count => (
        isa     => 'Int',
        is      => 'rw',
        lazy    => 1,
        default => sub { 1 },
    );

    has foo => (
      is => 'rw'
    );

    sub START {
        my ($self, $kernel, $session) = @_[OBJECT, KERNEL, SESSION];
        ::pass('Starting ');
        ::isa_ok($kernel, "POE::Kernel", "kernel in START");
        ::isa_ok($session, "POE::Session", "session in START");
        ::is($self->foo, 1, "foo attribute has correct value");
        $self->yield('dec');
    }

    event inc => sub {
        my ($self) = $_[OBJECT];
        ::pass( $self . ':' . $self->count );
        $self->count( $self->count + 1 );
        return if 3 < $self->count;
        $self->yield('inc');
    };

    sub on_dec {
        my ($self) = $_[OBJECT];
        ::pass( $self . ':' . $self->count );
        $self->count($self->count - 1 );
        $self->yield('inc');
    }

    sub STOP {
        ::pass('Stopping');
    }

    no MooseX::POE;
}

my @objs = map { Counter->new(foo => 1) } ( 1 .. $num_objs );# .. 10 );


Test::Memory::Cycle::memory_cycle_ok(\@objs, "no memory cycles") if $mem_cycle;

POE::Kernel->run();

Test::Memory::Cycle::memory_cycle_ok(\@objs, "no memory cycles") if $mem_cycle;
