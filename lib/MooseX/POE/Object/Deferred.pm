package MooseX::POE::Object::Deferred;
use Moose;

use metaclass 'MooseX::POE::Meta::Class';

extends qw(MooseX::POE::Object);


has '+_poe_session_id' => ( lazy => 1 );

sub start_session {
    my $self = shift;
    $self->get_session_id(); # force
}

no Moose;
1;
