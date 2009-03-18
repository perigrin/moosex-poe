package MooseX::POE::Meta::Class;
use Moose;
extends qw(MooseX::Async::Meta::Class);

# TODO: subclass events to be a hashref that maps the event to the method
# so we can support on_ events

override default_events => sub {
    my ($self) = @_;
    my $events = super();
    push @$events, grep { s/^on_(\w+)/$1/; } $self->get_method_list;
    return $events;
};

sub initialize {
    my $class = shift;
    my $pkg   = shift;

    $class->SUPER::initialize(
        $pkg,
        'instance_metaclass' => 'MooseX::POE::Meta::Instance',
        @_
    );
}

after add_role => sub {
  my ($self, $role) = @_;

  if ( $role->meta->does_role("MooseX::Async::Meta::Trait") ) {
      $self->add_event($role->get_events);
  }
};

override get_state_method_name => sub {
    my ( $self, $name ) = @_;
    return 'on_' . $name if $self->has_method( 'on_' . $name );
    return super();
};

no Moose;
1;
