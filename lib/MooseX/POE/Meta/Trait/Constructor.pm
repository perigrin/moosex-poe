package MooseX::POE::Meta::Trait::Constructor;

use Moose::Role;

# For CMOP 0.82_01+
sub _expected_method_class { "MooseX::POE::Meta::Trait::Object" }

# For older versions of Moose/CMOP
sub _expected_constructor_class { "MooseX::POE::Meta::Trait::Object" }

around _generate_instance => sub {
    my $orig = shift;
    my ($self, $var, $class_var) = @_;

    my %events = $self->_meta_instance->associated_metaclass->get_all_events;
    $events{STARTALL} = 'STARTALL';
    $events{_stop} = 'STOPALL';

    my $events = join(', ', map { 
      s/'/\\'/g;
      "'$_'"
    } %events);

    my $source = $orig->(@_) . <<"EOF"
my \$session = POE::Session->create(
    inline_states => { _start => sub { POE::Kernel->yield('STARTALL', \$_[5] ) }, },
    object_states => [
      $var => { $events }
    ],
    args => [ $var ],
    heap => (${var}->{heap} ||= {}),
);
${var}->{session_id} = \$session->ID;
EOF
};

no Moose::Role;

1;

__END__

=head1 NAME

MooseX::POE::Meta::Trait::Constructor

=head1 VERSION

This documentation refers to version 0.01.

=head1 SYNOPSIS

use MooseX::POE::Meta::Trait::Constructor;

=head1 DESCRIPTION

The MooseX::POE::Meta::Trait::Constructor class implements ...

=head1 SUBROUTINES / METHODS

There are no public methods.

=head1 DEPENDENCIES

Moose::Role

=head1 AUTHOR

Chris Prather (chris@prather.org)

=head1 LICENCE

Copyright 2009 by Chris Prather.

This software is free.  It is licensed under the same terms as Perl itself.

=cut
