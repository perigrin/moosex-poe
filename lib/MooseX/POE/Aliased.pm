package MooseX::POE::Aliased;
# ABSTRACT: A sane alias attribute for your MooseX::POE objects.
use MooseX::POE::Role;

use overload ();

use POE;

has alias => (
    isa => "Maybe[Str]",
    is  => "rw",
    builder     => "_build_alias",
    clearer     => "clear_alias",
    predicate   => "has_alias",
    trigger => sub {
        my ( $self, $alias ) = @_;

        # we cannot set the alias UNTIL we construct the object!
        # or ASSERT_DEFAULT will complain...
        return unless defined $self->get_session_id;
        $self->call( _update_alias => $alias );
    }
);

before 'STARTALL' => sub {
    my ($self) = @_;

    $self->call( _update_alias => $self->alias )
      if $self->has_alias;
};

sub _build_alias {
    my $self = shift;
    overload::StrVal($self);
}

event _update_alias => sub {
    my ( $kernel, $self, $alias ) = @_[KERNEL, OBJECT, ARG0];

    # we need to remove the prev alias like this because we don't know the
    # previous value.
    $kernel->alias_remove($_) for $kernel->alias_list( $self->get_session_id );
    $kernel->alias_set($alias) if defined $alias;

    return;
};

__PACKAGE__;

__END__

=pod

=head1 SYNOPSIS

	use MooseX::POE;

    with qw(MooseX::POE::Aliased);

    my $obj = Foo->new( alias => "blah" );

    $obj->alias("arf"); # previous one is removed, new one is set

    $obj->alias(undef); # no alias set

=head1 DESCRIPTION

This role provides an C<alias> attribute for your L<MooseX::POE> objects.

The attribute can be set, causing the current alias to be cleared and the new
value to be set.

=head1 ATTRIBUTES

=method alias

The alias to set for the session.

Defaults to the C<overload::StrVal> of the object.

If the value is set at runtime the alias will be updated in the L<POE::Kernel>.

A value of C<undef> inhibits aliasing.

=cut


