package MooseX::POE::Meta::Class;
use Moose;
extends qw(MooseX::Async::Meta::Class);

# TODO: subclass events to be a hashref that maps the event to the method
# so we can support on_ events

sub default_events {
    my ($self) = @_;
    my $events = $self->SUPER::default_events();
    push @$events, grep { s/^on_(\w+)/$1/; } $self->get_method_list;
    return $events;
}

sub initialize {
    my $class = shift;
    my $pkg   = shift;

    $class->SUPER::initialize(
        $pkg,
        'instance_metaclass' => 'MooseX::POE::Meta::Instance',
        @_
    );
}

sub get_state_method_name {
    my ( $self, $name ) = @_;
    return 'on_' . $name if $self->has_method( 'on_' . $name );
    return $self->SUPER::get_state_method_name($name);
}

no Moose;
1;
