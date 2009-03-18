package MooseX::POE::Role;
use Moose::Role;

use MooseX::POE::Meta::Role;
use Sub::Name 'subname';
use Sub::Exporter;

{
    my $CALLER;
    my %exports = (
        event => sub {
            my $class = $CALLER;
            return subname 'MooseX::POE::Role::event' => sub ($&) {
                my ( $name, $method ) = @_;
                $class->meta->add_state_method( $name => $method );
            };
        },
    );

    my $exporter = Sub::Exporter::build_exporter(
        {
            exports => \%exports,
            groups  => { default => [':all'] }
        }
    );

    sub import {
        my ( $pkg ) = @_;
        $CALLER = caller();
        strict->import;
        warnings->import;

        return if $CALLER eq 'main';

        my $meta_class   = 'MooseX::POE::Meta::Role';
        my $meta = Moose::Role->init_meta(for_class => $CALLER, metaclass => $meta_class);

        ## no critic
        eval qq{package $CALLER; use POE; };
        ## use critic
        die $@ if $@;

        goto $exporter;
    }
}

no Moose::Role;

1;
__END__

=head1 NAME

MooseX::POE::Role - Eventful roles

=head1 SYNOPSIS

    package Counter;
    use MooseX::POE::Role;

    ...

    package RealCounter;

    with qw(Counter);
  
=head1 DESCRIPTION

This is what Moose::Role is to Moose but with MooseX::POE.

=head1 KEYWORDS

=over

=item event $name $subref

Create an event handler named $name. 

=back

=cut
