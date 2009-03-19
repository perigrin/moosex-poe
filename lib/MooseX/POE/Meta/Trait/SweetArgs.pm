package MooseX::POE::Meta::Trait::SweetArgs;

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
