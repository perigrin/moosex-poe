package MooseX::Coro::Object;

use metaclass 'MooseX::Async::Meta::Class';

use Moose;
use Coro qw(:prio cede);

sub BUILD {
    $Coro::main->prio(PRIO_IDLE);
    $_[0]->yield('START');
}

sub START { }
sub STOP  { }

sub get_coro {
    my ( $self, $name ) = splice @_, 0, 2;
    if ( my $event = $self->can($name) ) {
        my $c = Coro->new( $event, $self, @_ );
        $c->desc( $self . "->$name" );
        return $c;
    }
}

sub yield {
    my ( $self, $name ) = splice @_, 0, 2;
    if ( my $c = $self->get_coro( $name, @_ ) ) {
        $c->ready;
        cede for Coro::nready;
    }
}

no Moose;
1;
