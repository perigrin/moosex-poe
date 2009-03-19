package MooseX::POE::SweetArgs;

use Moose ();
use MooseX::POE;
use Moose::Exporter;


Moose::Exporter->setup_import_methods(
    also        => 'MooseX::POE',
);

sub init_meta {
    my ($class, %args) = @_;
    MooseX::POE->init_meta(%args);
    $DB::single = 1;

    Moose::Util::MetaRole::apply_metaclass_roles(
      for_class => $args{for_class},
      metaclass_roles => [ 'MooseX::POE::Meta::Trait::SweetArgs' ],
    );
}


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
    POE::Kernel->yield('foo');
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
