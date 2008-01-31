package MooseX::POE::Meta::Instance;
use strict;
use Moose;
use POE;

extends 'Moose::Meta::Instance';

sub create_instance {
    my $self = shift;
    my $instance = $self->bless_instance_structure( {} );
    $instance->{session} = $self->get_new_session($instance);
    return $instance;
}

sub get_new_session {
    my ( $self, $instance ) = @_;
    my $meta = $self->associated_metaclass;
    return POE::Session->create(
        inline_states => { _start => sub { POE::Kernel->yield('STARTALL') }, },
        object_states => [
            $instance => {
              STARTALL => 'STARTALL',
              _stop  => 'STOPALL',
                map { $_ => $meta->get_state_method_name($_) }
                  map  { $_->meta->get_events }
                  grep { $_->meta->isa('MooseX::POE::Meta::Class') }
                  $meta->linearized_isa
            },
        ],
        args => [$instance],
        heap => {},
    );
}

sub get_session_id {
    my ( $self, $instance ) = @_;
    return $instance->{session}->ID;
}

sub get_slot_value {
    my ( $self, $instance, $slot_name ) = @_;
    return $instance->{session}->get_heap->{$slot_name};
}

sub set_slot_value {
    my ( $self, $instance, $slot_name, $value ) = @_;
    $instance->{session}->get_heap->{$slot_name} = $value;
}

sub is_slot_initialized {
    my ( $self, $instance, $slot_name, $value ) = @_;
    exists $instance->{session}->get_heap->{$slot_name} ? 1 : 0;
}

sub weaken_slot_value {
    my ( $self, $instance, $slot_name ) = @_;
    Scalar::Util::weaken( $instance->{session}->get_heap->{$slot_name} );
}

sub inline_slot_access {
    my ( $self, $instance, $slot_name ) = @_;
    sprintf "%s->{session}->get_heap->{%s}", $instance, $slot_name;
}

no Moose;
1;
__END__

=head1 NAME

MooseX::POE::Meta::Instance - A Instance Metaclass for MooseX::POE

=head1 SYNOPSIS

    use metaclass 'MooseX::Async::Meta::Class' => 
    ( instance_metaclass => 'MooseX::POE::Meta::Instance' );

  
=head1 DESCRIPTION

A metaclass for MooseX::POE. This module is only of use to developers 
so there is no user documentation provided.

=head1 METHODS

=over

=item create_instance

=item get_slot_value

=item inline_slot_access

=item is_slot_initialized

=item set_slot_value

=item weaken_slot_value

=item get_session_id

=item meta

The metaclass accessor provided by C<Moose::Object>.

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
