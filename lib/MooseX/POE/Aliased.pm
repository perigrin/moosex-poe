package MooseX::POE::Aliased;
use MooseX::POE::Role;

use overload ();

use POE;

has alias => (
    isa => "Str|Undef",
    is  => "rw",
    builder     => "_build_alias",
    clearer     => "clear_alias",
    initializer => sub {
        my ( $self, $alias, $cb, $attr ) = @_;
        $cb->($alias);
        $self->call( _update_alias => $alias );
    },
    trigger => sub {
        my ( $self, $alias ) = @_;
        $self->call( _update_alias => $alias );
    }
);

sub _build_alias {
    my $self = shift;
    overload::StrVal($self);
}

event _update_alias => sub {
    my ( $kernel, $self, $session, $alias ) = @_[KERNEL, OBJECT, SESSION, ARG0];

    # we need to remove the prev alias like this because we don't know the
    # previous value.
    $kernel->alias_remove($_) for $kernel->alias_list($session);

	$kernel->alias_set($alias) if defined $alias;
};

__PACKAGE__

__END__

=pod

=head1 NAME

MooseX::POE::Aliased - A sane C<alias> attribute for your L<MooseX::POE>
objects.

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

=over 4

=item alias

The alias to set for the session.

Defaults to the C<overload::StrVal> of the object.

If the value is set at runtime the alias will be updated in the L<POE::Kernel>.

A value of C<undef> inhibits aliasing.

=back

=cut


