package MooseX::POE::Object::Deferred;
use Moose;

use metaclass 'MooseX::POE::Meta::Class' =>
  ( instance_metaclass => 'MooseX::POE::Meta::Instance::Deferred' );

extends qw(MooseX::POE::Object);

sub start_session {
    my $self = shift;
    my $session = $self->meta->get_meta_instance->get_new_session($self);
    $self->{session_id}  = $session->ID;
    $self->{heap}        = $session->get_heap;
}

no Moose;
1;
