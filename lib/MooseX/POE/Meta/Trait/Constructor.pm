package MooseX::POE::Meta::Trait::Constructor;
# ABSTRACT: Yeah something even more boring

use Moose::Role;

around _generate_instance => sub {
    my $orig = shift;
    my ($self, $var, $class_var) = @_;

    my %events = $self->associated_metaclass->get_all_events;
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

=head1 SYNOPSIS

  use MooseX::POE::Meta::Trait::Constructor;

=head1 DESCRIPTION

The MooseX::POE::Meta::Trait::Constructor class implements ...

=head1 SUBROUTINES / METHODS

There are no public methods.

=cut
