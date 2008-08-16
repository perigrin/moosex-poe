package MooseX::POE::Meta::Role;
use Moose;

extends qw(Moose::Meta::Role);

with qw(MooseX::POE::Meta::Trait);

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
