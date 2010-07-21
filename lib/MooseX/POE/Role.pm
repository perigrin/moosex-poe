package MooseX::POE::Role;
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

=head1 NAME

MooseX::POE::Role - Eventful roles

=head1 SYNOPSIS

    package Counter;
    use MooseX::POE::Role;

    ...

    package RealCounter;

    with qw(Counter);
  
=head1 DESCRIPTION

This is what MooseX::POE is to Moose but with Moose::Role.

=head1 KEYWORDS

=over

=item event $name $subref

Create an event handler named $name. 

=back

=cut

=head1 SEE ALSO

L<MooseX::POE>

=head1 AUTHOR

Chris Prather  C<< <perigrin@cpan.org> >>

Ash Berlin C<< <ash@cpan.org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007-2009, Chris Prather C<< <perigrin@cpan.org> >>, Ash Berlin
C<< <ash@cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

