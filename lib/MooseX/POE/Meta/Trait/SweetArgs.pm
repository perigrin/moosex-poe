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
__END__

=head1 NAME

MooseX::POE::Meta::Trait::SweetArgs

=head1 VERSION

This documentation refers to version 0.01.

=head1 SYNOPSIS

use MooseX::POE::Meta::Trait::SweetArgs;

=head1 DESCRIPTION

The MooseX::POE::Meta::Trait::SweetArgs class implements ...

=head1 SUBROUTINES / METHODS

There are no public methods.

=head1 DEPENDENCIES

Moose::Role

=head1 AUTHOR

Chris Prather (chris@prather.org)

=head1 LICENCE

Copyright 2009 by Chris Prather.

This software is free.  It is licensed under the same terms as Perl itself.

=cut
