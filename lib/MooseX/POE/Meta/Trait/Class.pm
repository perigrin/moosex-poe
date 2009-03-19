package MooseX::POE::Meta::Trait::Class;

use Moose::Role;

with qw(MooseX::Async::Meta::Trait);

# TODO: subclass events to be a hashref that maps the event to the method
# so we can support on_ events

around default_events => sub {
    my ($next, $self) = @_;
    my $events = $next->($self);
    push @$events, grep { s/^on_(\w+)/$1/; } $self->get_method_list;
    return $events;
};

#around initialize => sub {
#    my ($next, $class, $pkg) = (shift, shift, shift);
#
#    $next->(
#        $class, 
#        $pkg,
#        'instance_metaclass' => 'MooseX::POE::Meta::Instance',
#        @_
#    );
#};
#
around add_role => sub {
  my ($next, $self, $role) = @_;
  
  $next->($self, $role);
  if ( $role->meta->does_role("MooseX::Async::Meta::Trait") ) {
      $self->add_event($role->get_events);
  }
};

around get_state_method_name => sub {
    my ( $next, $self, $name ) = @_;
    return 'on_' . $name if $self->has_method( 'on_' . $name );
    return $next->($self, $name);
};

no Moose::Role;
1;
