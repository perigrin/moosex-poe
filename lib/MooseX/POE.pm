package MooseX::POE;

our $VERSION = '0.213';

use Moose ();
use Moose::Exporter;

my ($import, $unimport, $init_meta) = Moose::Exporter->setup_import_methods(
    with_caller              => [qw(event)],
    also                     => 'Moose',
    install                  => [qw(import unimport)],
    metaclass_roles          => ['MooseX::POE::Meta::Trait::Class'],
    constructor_class_roles  => ['MooseX::POE::Meta::Trait::Constructor'],
    instance_metaclass_roles => ['MooseX::POE::Meta::Trait::Instance'],
    base_class_roles         => ['MooseX::POE::Meta::Trait::Object'],
);

sub init_meta {
    my ( $class, %args ) = @_;

    my $for = $args{for_class};
    eval qq{package $for; use POE; };

    Moose->init_meta( for_class => $for );

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

MooseX::POE - The Illicit Love Child of Moose and POE

=head1 VERSION

This document describes MooseX::POE version 0.205

=head1 SYNOPSIS

    package Counter;
    use MooseX::POE;

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

or with L<MooseX::Declare|MooseX::Declare>:

    class Counter {
        use MooseX::POE::SweetArgs qw(event);
        
        has count => (
            isa     => 'Int',
            is      => 'rw',
            lazy    => 1,
            default => sub { 0 },
        );
        
        sub START { 
            my ($self) = @_;
            $self->yield('increment')  
        }
        
        event increment => sub {
            my ($self) = @_;
            print "Count is now " . $self->count . "\n";
            $self->count( $self->count + 1 );
            $self->yield('increment') unless $self->count > 3;            
        }
    }

=head1 DESCRIPTION

MooseX::POE is a Moose wrapper around a POE::Session.

=head1 KEYWORDS

=over

=item event $name $subref

Create an event handler named $name. 

=back

=head1 METHODS

Default POE-related methods are provided by L<MooseX::POE::Meta::Trait::Object|MooseX::POE::Meta::Trait::Object>
which is applied to your base class (which is usually L<Moose::Object|Moose::Object>) when
you use this module. See that module for the documentation for. Below is a list
of methods on that class so you know what to look for:

=over

=item get_session_id

=item yield

=item call

=item STARTALL

=item STOPALL

=back


=head1 NOTES ON USAGE WITH L<MooseX::Declare|MooseX::Declare>

L<MooseX::Declare|MooseX::Declare> support is still "experimental". Meaning that I don't use it,
I don't have any code that uses it, and thus I can't adequately say that it
won't cause monkeys to fly out of any orafices on your body beyond what the
tests and the SYNOPSIS cover. 

That said there are a few caveats that have turned up during testing. 

1. The C<method> keyword doesn't seem to work as expected. This is an
integration issue that is being resolved but I want to wait for
L<MooseX::Declare|MooseX::Declare> to gain some more polish on their slurpy
arguments.

2. MooseX::POE attempts to re-export L<Moose|Moose>, which
L<MooseX::Declare|MooseX::Declare> has already exported in a custom fashion.
This means that you'll get a keyword clash between the features that
L<MooseX::Declare|MooseX::Declare> handles for you and the features that Moose
handles. To work around this you'll need to write:

    use MooseX::POE qw(event);
    # or
    use MooseX::POE::SweetArgs qw(event);
    # or 
    use MooseX::POE::Role qw(event);

to keep MooseX::POE from exporting the sugar that
L<MooseX::Declare|MooseX::Declare> doesn't like. This is fixed in the Git
version of L<MooseX::Declare|MooseX::Declare> but that version (as of this
writing) is not on the CPAN.

=head1 DEPENDENCIES

L<Moose|Moose> 

L<POE|POE>

=head1 AUTHOR

Chris Prather  C<< <chris@prather.org> >>

Ash Berlin C<< <ash@cpan.org> >>

Chris Williams C<<chris@bingosnet.co.uk>>

Yuval (nothingmuch) Kogman 

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007-2009, Chris Prather C<< <chris@prather.org> >>, Ash Berlin
C<< <ash@cpan.org> >>, Chris Williams C<<chris@bingosnet.co.uk>>, Yuval
(nothingmuch) Kogman. Some rights reserved.

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
