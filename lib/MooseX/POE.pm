package MooseX::POE;
our $VERSION = 0.100;
use Moose ();
use MooseX::POE::Meta::Class;
use MooseX::POE::Object;
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    with_caller => [qw(event)],
    also        => 'Moose',
);

sub init_meta {
    my ($class, %args) = @_;

    my $for = $args{for_class};
    eval qq{package $for; use POE; };
    
    return Moose->init_meta(
        %args,
        metaclass  => 'MooseX::POE::Meta::Class',
        base_class => 'MooseX::POE::Object'
    );
}

sub event {
    my ( $caller, $name, $method ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_state_method( $name => $method );
}

1;
__END__

=head1 NAME

MooseX::POE - The Illicit Love Child of Moose and POE

=head1 VERSION

This document describes MooseX::POE version 0.100

=head1 SYNOPSIS

    package Counter;
    use MooseX::POE;

    has name => (
        isa     => 'Str',
        is      => 'rw',
        default => sub { 'Foo ' },
    );

    has count => (
        isa     => 'Int',
        is      => 'rw',
        lazy    => 1,
        default => sub { 0 },
    );

    sub START {
        my ($self) = @_;
        $self->yield('increment');
    }

    event increment => sub {
        my ($self) = @_;
        print "Count is now " . $self->count . "\n";
        $self->count( $self->count + 1 );
        $self->yield('increment') unless $self->count > 3;
    };

    no MooseX::POE;
    
    Counter->new();
    POE::Kernel->run();
  
=head1 DESCRIPTION

MooseX::POE::Object is a Moose wrapper around a POE::Session.

=head1 KEYWORDS

=over

=item event $name $subref

Create an event handler named $name. 

=back

=head1 METHODS

Default methods are provided by L<MooseX::POE::Object> which is the default 
baseclass for MooseX::POE objects. These are the methods for the MooseX::POE 
package itself.

=over

=item import

Export the Moose Keywords as well as the C<event> keyword defined above.

=item unimport

Unexport the Moose Keywords as well as the C<event> keyword defined above.

=item meta

The metaclass accessor provided by C<Moose::Object>.

=back

=head1 DEPENDENCIES

L<Moose>, L<POE>, L<Sub::Name>, L<Sub::Exporter>


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
C<bug-moosex-poe@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Chris Prather  C<< <perigrin@cpan.org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, Chris Prather C<< <perigrin@cpan.org> >>. Some rights reserved.

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
