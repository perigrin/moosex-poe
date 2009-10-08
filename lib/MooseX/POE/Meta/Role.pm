package MooseX::POE::Meta::Role;
use Moose::Role;
with qw(MooseX::POE::Meta::Trait);

around default_events => sub {
    my ( $orig, $self ) = @_;
    my $events = $orig->($self);
    push @$events, grep { s/^on_(\w+)/$1/; } $self->get_method_list;
    return $events;
};

around get_state_method_name => sub {
    my ( $orig, $self, $name ) = @_;
    return 'on_' . $name if $self->has_method( 'on_' . $name );
    return $orig->( $self, $name );
};


no Moose::Role;

1;

