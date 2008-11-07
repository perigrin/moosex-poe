package MooseX::POE::SweetArgs;

use Moose;
extends qw(MooseX::POE::Meta::Class);

around add_state_method => sub {
  my $orig = shift;
  my ($self, $name, $method) = @_;
  $orig->($self, $name, sub {
    $method->(@_[POE::Session::OBJECT(), POE::Session::ARG0()..$#_])
  });
}; 

1;

=head1 NAME

MooseX::POE::SweetArgs - sugar around MooseX::POE event arguments

=head1 SYNOPSIS

  package Thing;

  # must come before MooseX::POE!
  use metaclass 'MooseX::POE::SweetArgs';
  use MooseX::POE;

  # declare events like usual
  event on_success => sub {
    # unpack args like a Perl sub, not a POE event
    my ($self, $foo, $bar) = @_;
    ...
  };

=head1 DESCRIPTION

Normally, when using MooseX::POE, subs declared as events need to use POE
macros for unpacking C<@_>, e.g.:

  my ($self, $foo, $bar) = @_[OBJECT, ARG0..$#_];

Using MooseX::POE::SweetArgs as a metaclass lets you avoid this, and just use
C<@_> as normal:

  my ($self, $foo, $bar) = @_;

=cut
