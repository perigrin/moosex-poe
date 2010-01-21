package MooseX::POE::Meta::Trait::Class;

use Moose::Role;

with qw(MooseX::POE::Meta::Trait);

# TODO: subclass events to be a hashref that maps the event to the method
# so we can support on_ events

around default_events => sub {
    my ( $next, $self ) = @_;
    my $events = $next->($self);
    push @$events, grep { s/^on_(\w+)/$1/; } $self->get_method_list;
    return $events;
};

around add_role => sub {
    my ( $next, $self, $role ) = @_;
    $next->( $self, $role );
warn $role;
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
        map { $_->meta } grep { $_->can('meta') } $self->linearized_isa;
    return %events;
}

no Moose::Role;
1;
__END__

=head1 NAME

MooseX::POE::Meta::Trait::Class

=head1 SYNOPSIS

    use MooseX::POE::Meta::Trait::Constructor;

=head1 DESCRIPTION

The MooseX::POE::Meta::Trait::Constructor class implements ...

=head1 METHODS

=over 

=item get_all_events

=back 

=head1 DEPENDENCIES

Moose::Role

=head1 AUTHOR

Chris Prather (chris@prather.org)

=head1 LICENCE

Copyright 2009 by Chris Prather.

This software is free.  It is licensed under the same terms as Perl itself.

=cut
