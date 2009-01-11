package MooseX::POE::Meta::Trait;
use Moose::Role;

with 'MooseX::Async::Meta::Trait' => {
    excludes => [qw(get_events)],
};

sub filter_event_methods {
    my ($self, @methods) = @_;

    # FIXME make into a does_role test
    grep { $_->isa("MooseX::Async::Meta::Method::State") } @methods;
}

sub get_events {
    my $self = shift;
    $self->filter_event_methods( $self->get_methods );
}

sub get_all_events {
    my $self = shift;
    $self->filter_event_methods( $self->get_all_methods );
}

__PACKAGE__

__END__

