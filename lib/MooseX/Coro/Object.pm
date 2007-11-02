package MooseX::Coro::Object;

use metaclass 'MooseX::Async::Meta::Class';

use Moose;
use Coro;

sub BUILD {
    $_[0]->yield('START');
    $_[0]->yield('STOP');
}

sub START { }
sub STOP { cede while Coro::nready; }

sub yield {
    my ( $self, $name ) = splice @_, 0, 2;
    if ( my $event = $self->can($name) ) {
        Coro->new( $event, $self, @_ )->ready;
        cede;
    }
}

no Moose;
1;
