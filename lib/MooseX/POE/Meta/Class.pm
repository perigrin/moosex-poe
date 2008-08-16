package MooseX::POE::Meta::Class;
use Moose;

extends qw(Moose::Meta::Class);

with qw(MooseX::POE::Meta::Class::Trait);

__PACKAGE__->meta->make_immutable;

no Moose;
1;
