package MooseX::POE::Object::Deferred;
use Moose;

use metaclass 'MooseX::POE::Meta::Class' =>
  ( instance_metaclass => 'MooseX::POE::Meta::Instance::Deferred' );

extends qw(MooseX::POE::Object);

sub start_session {
    $self->{session} = $self->meta->get_meta_instance->get_new_session($self);
}

no Moose;
1;
