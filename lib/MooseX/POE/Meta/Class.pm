package MooseX::POE::Meta::Class;
use strict;
use Moose;
use B 'svref_2object';
extends qw(Moose::Meta::Class);

sub initialize {
    my $class = shift;
    my $pkg   = shift;
    $class->SUPER::initialize(
        $pkg,
        'instance_metaclass' => 'MooseX::POE::Meta::Instance',
        @_
    );
}

sub add_state_method {
    my ( $self, $name, $method ) = @_;
    ( !$self->has_method($name) )
      || confess
      "Cannot add an augment method if a local method is already present";
    $self->add_method( MooseX::POE::Meta::Method::Event->wrap() );
}

#XXX: Ick we had to copy the entire thing from Class::MOP::Class
#     because there was no easy way to subclass it
sub get_method_map {
    my $self = shift;
    my $map  = $self->{'%!methods'};

    my $class_name       = $self->name;
    my $method_metaclass = $self->method_metaclass;

    foreach my $symbol ( $self->list_all_package_symbols('CODE') ) {

        # if the method starts with 'on_' we want our custom metaclass
        $method_metaclass = 'MooseX::POE::Meta::Method::State'
          if $symbol =~ /^on_|^(?:START|STOP|CHILD|PARENT|DEFAULT)$/;

        my $code = $self->get_package_symbol( '&' . $symbol );

        next
          if exists $map->{$symbol}
          && defined $map->{$symbol}
          && $map->{$symbol}->body == $code;

        my $gv = svref_2object($code)->GV;
        next
          if ( $gv->STASH->NAME || '' ) ne $class_name
          && ( $gv->NAME || '' ) ne '__ANON__';

        $map->{$symbol} = $method_metaclass->wrap($code);
    }

    return $map;
}

no Moose;
1;
__END__

=head1 NAME

MooseX::POE::Meta::Class - A Class Metaclass for MooseX::POE

=head1 SYNOPSIS

    metaclass 'MooseX::POE::Meta::Class';
  
=head1 DESCRIPTION

A metaclass for MooseX::POE. This module is only of use to developers 
so there is no user documentation provided.

=head1 METHODS

=over

=item initialize

=item add_state_method

=item get_method_map

=item meta

=back

=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

L<Moose::Meta::Class>, L<MooseX::POE::Meta::Instance>


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-moose-poe-object@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Chris Prather  C<< <perigrin@cpan.org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, Chris Prather C<< <perigrin@cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
