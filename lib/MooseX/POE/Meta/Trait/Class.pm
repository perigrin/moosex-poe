package MooseX::POE::Meta::Trait::Class;
# ABSTRACT: No achmed inside
use Moose::Role;

with qw(MooseX::POE::Meta::Trait);

# TODO: subclass events to be a hashref that maps the event to the method
# so we can support on_ events

around new_object => sub {
    my ( $next, $self, @args ) = @_;
    my $instance = $next->($self, @args);

    my $session = POE::Session->create(
        inline_states =>
            { _start => sub { POE::Kernel->yield('STARTALL') }, },
        object_states => [
            $instance => {
                $self->get_all_events,
                STARTALL => 'STARTALL',
                _stop    => 'STOPALL',
                _child   => 'CHILD',
                _parent  => 'PARENT',
                _call_kernel_with_my_session => '_call_kernel_with_my_session',
            },
        ],
        args => [$instance],
        heap => ( $instance->{heap} ||= {} ),
    );
    $instance->{session_id} = $session->ID;

    return $instance;
};

around default_events => sub {
    my ( $next, $self ) = @_;
    my $events = $next->($self);
    push @$events, grep { s/^on_(\w+)/$1/; } $self->get_method_list;
    return $events;
};

around add_role => sub {
    my ( $next, $self, $role ) = @_;
    $next->( $self, $role );

    if (   $role->meta->can('does_role')
        && $role->meta->does_role("MooseX::POE::Meta::Trait") ) {
        $self->add_event( $role->get_events );
    }
};

around get_state_method_name => sub {
    my ( $next, $self, $name ) = @_;
    return 'on_' . $name if $self->has_method( 'on_' . $name );
    return $next->( $self, $name );
};

sub get_all_events {
    my ($self) = @_;
    my $wanted_role = 'MooseX::POE::Meta::Trait';

    # This horrible grep can be removed once Moose gets more metacircular.
    # Currently Moose::Meta::Class->meta isn't a MMC. It should be, and it
    # should also be a Moose::Object so does works on it.
    my %events
        = map {
        my $m = $_;
        map { $_ => $m->get_state_method_name($_) } $m->get_events
        }
        grep {
        $_->meta->can('does_role') && $_->meta->does_role($wanted_role)
        }
        map { $_->meta } $self->linearized_isa;
    return %events;
}

no Moose::Role;
1;
__END__

=head1 METHODS

=method get_all_events

=head1 DEPENDENCIES

Moose::Role

=cut
