package MooseX::POE::SweetArgs;
# ABSTRACT: sugar around MooseX::POE event arguments

use Moose ();
use MooseX::POE;
use Moose::Exporter;


Moose::Exporter->setup_import_methods(
    also        => 'MooseX::POE',
);

sub init_meta {
    my ($class, %args) = @_;
    MooseX::POE->init_meta(%args);

    Moose::Util::MetaRole::apply_metaroles(
        for             => $args{for_class},
        class_metaroles => {
            class => ['MooseX::POE::Meta::Trait::SweetArgs'],
        },
    );
}


1;
__END__

=head1 SYNOPSIS

  package Thing;
  use MooseX::POE::SweetArgs;

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

Since the POE kernel is a singleton, you can access it using class methods, as
shown in the synopsis.

In all other respects, this behaves exactly like MooseX::POE

=for :list
* L<MooseX::POE|MooseX::POE>
