#!/usr/bin/perl
# written by Rob Bloodgood aka LordVorp on irc.perl.org
# based upon http://poe.perl.org/?POE_Cookbook/Serial_Ports

package SerialWatcher;
use MooseX::POE::SweetArgs;

use Symbol qw(gensym);
use Device::SerialPort;
use POE::Filter::Line;
use POE::Wheel::ReadWrite;
use POE::Wheel::ReadLine;

has port_handle => (
    is      => 'ro',
    isa     => 'GlobRef',
    lazy    => 1,
    default => sub { gensym() }
);

has port => (
    is         => 'ro',
    isa        => 'Device::SerialPort',
    lazy_build => 1,
);

sub _build_port {
    my ($self) = @_;

    my $port = tie( *{ $self->port_handle }, "Device::SerialPort", "/dev/ttyS1" )
        or die "can't open port: $!";

    $port->datatype('raw');
    $port->baudrate(9600);
    $port->databits(8);
    $port->parity("none");
    $port->stopbits(1);
    $port->handshake("rts");
    $port->write_settings();

    $port;
}

has device => (
    is         => 'ro',
    isa        => 'POE::Wheel::ReadWrite',
    lazy_build => 1,
);

# instantiates the wheel that talks to the device
sub _build_device {
    my ($self) = @_;

    my $filter = POE::Filter::Line->new(
        InputLiteral  => "\x0D\x0A",    # Received line endings.
        OutputLiteral => "\x0D",        # Sent line endings.
    );

    $self->port; # initalize the port and port_handle here so we can use the handle below
    POE::Wheel::ReadWrite->new(
        Handle     => $self->port_handle,
        Filter     => $filter,
        InputEvent => "got_port",
        ErrorEvent => "got_error",
    );
}

has console => (
    is         => 'ro',
    isa        => 'POE::Wheel::ReadLine',
    lazy_build => 1,
);

# and the wheel that talks to the console
sub _build_console {
    my ($self) = @_;

    POE::Wheel::ReadLine->new( InputEvent => "got_console" );
}

sub START {
    my $self = shift;

    # make sure our wheels are started up *in the session*
    $self->device;
    $self->console;
}

event got_port => sub {    # wheel gave us some data:
    my ( $self, $data ) = @_;    # [OBJECT, ARG0];
    $self->console->put($data);
};

event got_console => sub {
    my ( $self, $input ) = @_;    # [OBJECT, ARG0];
    if ( defined $input ) {
        $self->console->addhistory($input);
        $self->device->put($input);
        $self->console->get("Ready: ");

        # Clearing $! after $serial_device->put() seems to work around
        # an issue in Device::SerialPort 1.000_002.

        $! = 0;
        return;
    }

    # clearer's are created by lazy_build
    $self->console->put("Bye!");
    $self->clear_device;
    $self->clear_console;
};

event got_error => sub {
    my ( $self, @args) = @_;    # [OBJECT, ARG0...$#_ ];

    $self->console->put("$args[0] error $args[1]: $args[2]");
    $self->console->put("Bye!");

    $self->clear_device;
    $self->clear_console;

};

no MooseX::POE;

package main;

SerialWatcher->new();
POE::Kernel->run();

