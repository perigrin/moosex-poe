package MooseX::POE::Meta::Trait;
use Moose::Role;

use MooseX::POE::Meta::Method::State;

has events => (
    reader     => 'get_events',
    traits     => ['Array'],
    isa        => 'ArrayRef',
    auto_deref => 1,
    lazy_build => 1,
    builder    => 'default_events',
    handles    => { 'add_event' => ['push'] },
);

sub default_events {
    return [];
}

sub get_state_method_name {
    my ( $self, $name ) = @_;
    return $name if $self->has_method($name);
    return undef;
}

sub add_state_method {
    my ( $self, $name, $method ) = @_;
    if ( $self->has_method($name) ) {
        my $full_name = $self->get_method($name)->fully_qualified_name;
        confess
"Cannot add a state method ($name) if a local method ($full_name) is already present";
    }

    $self->add_event($name);
    $self->add_method( $name => $method );
}

after add_role => sub {
    my ( $self, $role ) = @_;

    if ( $role->isa("MooseX::POE::Meta::Role") ) {
        $self->add_event( $role->get_events );
    }
};

1;
