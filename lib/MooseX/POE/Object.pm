package MooseX::POE::Object;
use strict;
our $VERSION = '0.050';

use POE;

use metaclass 'MooseX::POE::Meta::Class';

use Moose;

has _poe_session_id => (
    reader   => "get_session_id",
    init_arg => undef,
    isa      => "Int",
    builder  => "_build_poe_session_id",
);

sub _build_poe_session_id {
    my $self = shift;
    Class::MOP::Class->initialize(ref $self)->get_new_session($self)->ID;
}

sub yield { my $self = shift; POE::Kernel->post( $self->get_session_id, @_ ) }

sub call { my $self = shift; POE::Kernel->call( $self->get_session_id, @_ ) }

sub _start {
  $_[KERNEL]->yield('STARTALL');
}

__PACKAGE__->meta->add_method(
    _start => MooseX::Async::Meta::Method::State->wrap(
        body  => \&_start,
        name  => "_start",
        event => "_start",
        package_name => __PACKAGE__,
    ),
);

sub STARTALL {
    # NOTE: we ask Perl if we even 
    # need to do this first, to avoid
    # extra meta level calls
  return unless $_[0]->can('START');    
  my ($self, @params) = @_;
  foreach my $method (reverse $self->meta->find_all_methods_by_name('START')) {
    $method->{code}->($self, @params);
  }
}

__PACKAGE__->meta->add_method(
    STARTALL => MooseX::Async::Meta::Method::State->wrap(
        body  => \&STARTALL,
        name  => "STARTALL",
        event => "STARTALL",
        package_name => __PACKAGE__,
    ),
);


sub STOPALL {
    # NOTE: we ask Perl if we even 
    # need to do this first, to avoid
    # extra meta level calls
  return unless $_[0]->can('STOP');    
  my ($self, $params) = @_;
  foreach my $method (reverse $self->meta->find_all_methods_by_name('STOP')) {
    $method->{code}->($self, $params);
  }
}

__PACKAGE__->meta->add_method(
    STOPALL => MooseX::Async::Meta::Method::State->wrap(
        body  => \&STOPALL,
        name  => "STOPALL",
        event => "STOPALL",
        package_name => __PACKAGE__,
    ),
);

no Moose;  # unimport Moose's keywords so they won't accidentally become methods
1;         # Magic true value required at end of module
__END__

=head1 NAME

MooseX::POE::Object - The base class for MooseX::Poe


=head1 VERSION

This document describes Moose::POE::Object version 0.0.1


=head1 SYNOPSIS

    package Counter;
    use MooseX::Poe;

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

    sub increment {
        my ($self) = @_;
        $self->count( $self->count + 1 );
        $self->yield('increment') unless $self->count > 3;
    }

    no MooseX::Poe;

  
=head1 DESCRIPTION

MooseX::POE::Object is a Moose::Object subclass that implements a POE::Session

=head1 DEFAULT METHODS

=over

=item get_session_id

Get the internal Session ID, this is useful to hand to other POE aware functions.

=item yield

A cheap alias for POE::Kernel->yield() which will gurantee posting to the object's session.

=item meta 

The metaclass accessor provided by C<Moose::Object>.

=back

=head1 PREDEFINED EVENTS 

=over

=item START

=item STOP

=item DEFAULT

=item CHILD

=item PARENT

=back

=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

L<Moose>, L<POE>


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
