package MooseX::POE::Meta::Role;
use Moose::Role;
with qw(MooseX::Async::Meta::Trait);

sub default_events {
    my ($self) = @_;
    my $events = $self->SUPER::default_events();
    push @$events, grep { s/^on_(\w+)/$1/; } $self->get_method_list;
    return $events;
}

sub get_state_method_name {
    my ( $self, $name ) = @_;
    return 'on_' . $name if $self->has_method( 'on_' . $name );
    return $self->SUPER::get_state_method_name($name);
}

no Moose::Role;

1;

