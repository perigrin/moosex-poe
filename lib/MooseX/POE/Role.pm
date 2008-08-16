package MooseX::POE::Role;
use Moose;
use MooseX::POE::Meta::Role;

use Moose::Role ();

with qw(MooseX::POE::Exporter);

__PACKAGE__->setup_import_methods();

sub _also_import { "Moose::Role" }

sub _init_params {
    metaclass  => "MooseX::POE::Meta::Role",
}

no Moose;
1;
__END__

=head1 NAME

MooseX::POE::Role - Eventful roles

=head1 SYNOPSIS

    package Counter;
    use MooseX::POE::Role;

    ...

    package RealCounter;

    with qw(Counter);
  
=head1 DESCRIPTION

This is what Moose::Role is to Moose but with MooseX::POE.

=head1 KEYWORDS

=over

=item event $name $subref

Create an event handler named $name. 

=back

=cut
