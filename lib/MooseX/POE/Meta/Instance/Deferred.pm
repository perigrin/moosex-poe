package MooseX::POE::Meta::Instance::Deferred;
use Moose;

extends qw(MooseX::POE::Meta::Instance);

sub create_instance {
    my $self = shift;
    return $self->bless_instance_structure( {} );
}

no Moose;
1;
