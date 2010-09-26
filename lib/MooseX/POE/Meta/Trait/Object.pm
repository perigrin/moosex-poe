package MooseX::POE::Meta::Trait::Object;

use Moose::Role;
use POE::Session;

sub new {
    my $class  = shift;
    my $params = $class->BUILDARGS(@_);
    my $self   = $class->meta->new_object($params);

    my $session = POE::Session->create(
        inline_states =>
            { _start => sub { POE::Kernel->yield('STARTALL') }, },
        object_states => [
            $self => {
                $self->meta->get_all_events,
                STARTALL => 'STARTALL',
                _stop    => 'STOPALL',
                _child   => 'CHILD',
                _parent  => 'PARENT',
                _alarm   => '_alarm',
                _alarm_add => '_alarm_add',
                _delay   => '_delay',
                _delay_add => '_delay_add',
                _alarm_set => '_alarm_set',
                _alarm_adjust => '_alarm_adjust',
                _alarm_remove => '_alarm_remove',
                _alarm_remove_all => '_alarm_remove_all',
                _delay_set => '_delay_set',
                _delay_adjust => '_delay_adjust',
            },
        ],
        args => [$self],
        heap => ( $self->{heap} ||= {} ),
    );
    $self->{session_id} = $session->ID;

    $self->BUILDALL($params);
    return $self;
}

sub get_session_id {
    my ($self) = @_;
    return $self->meta->get_meta_instance->get_session_id($self);
}

sub yield { my $self = shift; POE::Kernel->post( $self->get_session_id, @_ ) }

sub call { my $self = shift; POE::Kernel->call( $self->get_session_id, @_ ) }

sub alarm { my $self = shift; $self->call( _alarm => @_ ) }
sub _alarm { my ( $self, @args ) = @_[ OBJECT, ARG0..$#_ ]; POE::Kernel->alarm( @args ) }

sub alarm_add { my $self = shift; $self->call( _alarm_add => @_ ) }
sub _alarm_add { my ( $self, @args ) = @_[ OBJECT, ARG0..$#_ ]; POE::Kernel->alarm_add( @args ) }

sub delay { my $self = shift; $self->call( _delay => @_ ) }
sub _delay { my ( $self, @args ) = @_[ OBJECT, ARG0..$#_ ]; POE::Kernel->delay( @args ) }

sub delay_add { my $self = shift; $self->call( _delay_add => @_ ) }
sub _delay_add { my ( $self, @args ) = @_[ OBJECT, ARG0..$#_ ]; POE::Kernel->delay_add( @args ) }

sub alarm_set { my $self = shift; $self->call( _alarm_set => @_ ) }
sub _alarm_set { my ( $self, @args ) = @_[ OBJECT, ARG0..$#_ ]; POE::Kernel->alarm_set( @args ) }

sub alarm_adjust { my $self = shift; $self->call( _alarm_adjust => @_ ) }
sub _alarm_adjust { my ( $self, @args ) = @_[ OBJECT, ARG0..$#_ ]; POE::Kernel->alarm_adjust( @args ) }

sub alarm_remove { my $self = shift; $self->call( _alarm_remove => @_ ) }
sub _alarm_remove { my ( $self, @args ) = @_[ OBJECT, ARG0..$#_ ]; POE::Kernel->alarm_remove( @args ) }

sub alarm_remove_all { my $self = shift; $self->call( _alarm_remove_all => @_ ) }
sub _alarm_remove_all { my ( $self, @args ) = @_[ OBJECT, ARG0..$#_ ]; POE::Kernel->alarm_remove_all( @args ) }

sub delay_set { my $self = shift; $self->call( _delay_set => @_ ) }
sub _delay_set { my ( $self, @args ) = @_[ OBJECT, ARG0..$#_ ]; POE::Kernel->delay_set( @args ) }

sub delay_adjust { my $self = shift; $self->call( _delay_adjust => @_ ) }
sub _delay_adjust { my ( $self, @args ) = @_[ OBJECT, ARG0..$#_ ]; POE::Kernel->delay_adjust( @args ) }

sub STARTALL {
    my ( $self, @params ) = @_;
    $params[4] = pop @params;
    foreach
        my $method ( reverse $self->meta->find_all_methods_by_name('START') )
    {
        $method->{code}->( $self, @params );
    }
}

sub STOPALL {
    my ( $self, $params ) = @_;
    foreach
        my $method ( reverse $self->meta->find_all_methods_by_name('STOP') ) {
        $method->{code}->( $self, $params );
    }
}

sub START  { }
sub STOP   { }
sub CHILD  { }
sub PARENT { }

# __PACKAGE__->meta->add_method( _stop => sub { POE::Kernel->call('STOP') } );

__PACKAGE__->meta->add_method(
    _default => __PACKAGE__->meta->get_method('DEFAULT') )
    if __PACKAGE__->meta->has_method('DEFAULT');

__PACKAGE__->meta->add_method(
    _child => __PACKAGE__->meta->get_method('CHILD') )
    if __PACKAGE__->meta->has_method('CHILD');

__PACKAGE__->meta->add_method(
    _parent => __PACKAGE__->meta->get_method('PARENT') )
    if __PACKAGE__->meta->has_method('PARENT');
	
no Moose::Role;

1;

__END__

=head1 NAME

MooseX::POE::Meta::Trait::Object - The base class role for MooseX::Poe

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

MooseX::POE::Meta::TraitObject is a role that is applied to the object base
classe (usually Moose::Object) that implements a POE::Session.

=head1 DEFAULT METHODS

=over

=item get_session_id

Get the internal POE Session ID, this is useful to hand to other POE aware
functions.

=item yield

A cheap alias for POE::Kernel->yield() which will gurantee posting to the object's session.

=item STARTALL

Along similar lines to Moose's C<BUILDALL> method which calls all the C<BUILD>
methods, this function will call all the C<START> methods in your inheritance
hierarchy automatically when POE first runs your session. (This corresponds to
the C<_start> event from POE.)

=item STOPALL

Along similar lines to C<STARTALL>, but for C<STOP> instead.

=back

=head1 PREDEFINED EVENTS 

=over

=item START

=item STOP

=item DEFAULT

=item CHILD

=item PARENT

=back


=head1 AUTHOR

Chris Prather  C<< <perigrin@cpan.org> >>

Ash Berlin C<< <ash@cpan.org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007-2009, Chris Prather C<< <perigrin@cpan.org> >>, Ash Berlin
C<< <ash@cpan.org> >>. All rights reserved.

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
