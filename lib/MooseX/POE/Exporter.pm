#!/usr/bin/perl

package MooseX::POE::Exporter;
use Moose::Role;

use MooseX::POE::Exporter;

requires qw(_init_params _also_import);

sub event {
    my ( $class, $name, $body ) = @_;
    MooseX::POE::Meta::Class->initialize($class)->add_method( "on_$name" =>
        MooseX::Async::Meta::Method::State->wrap(
            event => $name,
            name  => "on_$name",
            body  => $body,
            package_name => $class,
        ),
    );
}

sub setup_import_methods {
    my $class = shift;

    Moose::Exporter->setup_import_methods(
        exporting_package => $class,
        export            => [qw(event)],
        with_caller       => [qw(event)],
        also              => $class->_also_import,
    );
}

sub init_meta {
    my ( $pkg, %args ) = @_;

    my $class = $args{for_class};

    ## no critic
    eval qq{package $class; use POE; };
    ## use critic
    die $@ if $@;

    $pkg->_also_import->init_meta( $pkg->_init_params, %args );
}

__PACKAGE__

__END__
