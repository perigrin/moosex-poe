package MooseX::POE::Meta::Trait::SweetArgs;
# ABSTRACT: Yes, its a trap... i mean trait

use Moose::Role;

around add_state_method => sub {
  my $orig = shift;
  my ($self, $name, $method) = @_;
  $orig->($self, $name, sub {
    $method->(@_[POE::Session::OBJECT(), POE::Session::ARG0()..$#_])
  });
};

no Moose::Role;

1;
__END__

=head1 SYNOPSIS

use MooseX::POE::Meta::Trait::SweetArgs;

=head1 DESCRIPTION

The MooseX::POE::Meta::Trait::SweetArgs class implements ...

=head1 SUBROUTINES / METHODS

There are no public methods.
