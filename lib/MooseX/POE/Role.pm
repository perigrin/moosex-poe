package MooseX::POE::Role;
# ABSTRACT: Eventful roles
use MooseX::POE::Meta::Role;

use Moose::Exporter;

my ( $import, $unimport, $init_meta ) = Moose::Exporter->setup_import_methods(
    with_caller    => [qw(event)],
    also           => 'Moose::Role',
    install        => [qw(import unimport)],
    role_metaroles => {
        role => ['MooseX::POE::Meta::Role'],
    },
);

sub init_meta {
    my ( $class, %args ) = @_;

    my $for = $args{for_class};
    eval qq{package $for; use POE; };

    Moose::Role->init_meta( for_class => $for );

    goto $init_meta;
}

sub event {
    my ( $caller, $name, $method ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_state_method( $name => $method );
}


1;
__END__

=head1 SYNOPSIS

    package Counter;
    use MooseX::POE::Role;

    ...

    package RealCounter;

    with qw(Counter);
  
=head1 DESCRIPTION

This is what L<MooseX::POE> is to Moose but with L<Moose::Role>.

=head1 KEYWORDS

=method event $name $subref

Create an event handler named $name. 

=for :list
* L<MooseX::POE|MooseX::POE>
* L<Moose::Role> 

