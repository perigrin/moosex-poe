package MooseX::POE::Role;

use MooseX::POE::Meta::Role;

use Moose::Exporter;

sub event ($&) {
  my ( $class, $name, $method ) = @_;
  $class->meta->add_state_method( $name => $method );
}

Moose::Exporter->setup_import_methods(
  with_caller => [ qw/event/ ],
  also => 'Moose::Role'
);

sub init_meta {
  my ($class, %p) = @_;

  my $for = $p{for_class};

  eval qq{package $for; use POE; };

  my $meta;
  unless ($for->can('meta')) {
    $meta = Moose::Role->init_meta(for_class => $for);
  } else {
    $meta = $for->meta;
  }

  Moose::Util::MetaRole::apply_metaclass_roles(
    for_class => $p{for_class},
    metaclass_roles => ['MooseX::POE::Meta::Role']
  );
}

no Moose::Role;

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

