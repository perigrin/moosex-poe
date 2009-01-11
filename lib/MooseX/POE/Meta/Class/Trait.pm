package MooseX::POE::Meta::Class::Trait;
use Moose::Role;

with qw(MooseX::POE::Meta::Trait);

sub get_new_session {
    my ( $self, $instance ) = @_;

    return POE::Session->create(
        object_states => [
            $instance => {
                _start   => '_start',
                STARTALL => "STARTALL",
                _stop    => 'STOPALL',
                ( map  { $_->event => $_->name } $self->get_all_events ),
                # ( map { $_ => "on_$_" } grep { warn $_; s/^on_// } $self->list_all_methods ), # compat
            },
        ],
        args => [$instance],
        heap => {},
    );
}

sub get_session_id {
    my ( $self, $instance ) = @_;
    $self->get_attribute("_poe_session_id")->get_value($instance);
}

1;
