#!/usr/bin/env perl 

# This is a little test program to see if we could implement
# http://candygram.sourceforge.net/node6.html on MooseX::POE
# using MX::Poe objects (aka POE::Sessions) to replace threads

# Here is the relevant code from Canygram
#
#
# >>> import candygram as cg
# >>> import time
# >>> def proc_func():
# ...     r = cg.Receiver()
# ...     r.addHandler('land shark', shut_door, cg.Message)
# ...     r.addHandler('candygram', open_door, cg.Message)
# ...     for message in r:
# ...         print message
# ...
# >>> def shut_door(name):
# ...     return 'Go Away ' + name
# ...
# >>> def open_door(name):
# ...     return 'Hello ' + name
# ...
# >>> proc = cg.spawn(proc_func)
# >>> proc.send('land shark')
# >>> proc.send('candygram')
# >>> # Give the proc a chance to print its messages before termination:
# ... time.sleep(1)

#
# here is our version
#
sub main {

    sub proc_func {
        my $r = $_[0]->reciever;
        $r->add_handler( 'land_shark', \&shut_door );
        $r->add_handler( 'candygram',  \&open_door );
        while (<$r>) {
            print;
        }
    }

    sub shut_door {
        return 'Go away ' . $_[1];
    }

    sub open_door {
        return 'Hello ' . $_[1];
    }

    my $proc = Candygram->spawn( \&proc_func );
    $proc->send('land_shark');
    $proc->send('candygram');
    POE::Kernel->run;    # we have to run the kernel manually
    
}

{

    package Candygram;

    sub spawn {
        my ( $self, $func ) = splice @_, 0, 2;
        return Proc->new( func => $func, args => \@_ );
    }

}

{

    package Receiver;
    use Moose;
    use overload '<>' => \&receive;

    has mailbox => (
        isa        => 'ArrayRef',
        is         => 'ro',
        auto_deref => 1,
        default    => sub { [] },
    );

    has handlers => (
        isa     => 'HashRef',
        is      => 'ro',
        default => sub { {} },
    );

    sub add_handler {
        my ( $self, $state, $code ) = @_;
        return if exists $self->handlers->{$state};
        $self->handlers->{$state} = $code;
    }

    sub receive {
        my $self = shift;
        my ( $state, $args );
        return unless scalar @{ $self->mailbox };
        for ( 0 .. $#{ $self->mailbox } ) {
            my $state = $self->mailbox->[$_]->[0];
            next unless $state;
            next unless exists $self->handlers->{$state};
            ( $state, $args ) = @{ splice @{ $self->mailbox }, $_, 1 };
            if ( $state && $args ) {
                my $res = $self->handlers->{$state}->(@$args);
                return $res;
            }
        }
        return;
    }
}

{

    package Proc;
    use MooseX::POE;

    has func => (
        isa     => 'CodeRef',
        is      => 'ro',
        default => sub {
            sub { }
        },
    );
    has args => (
        isa        => 'ArrayRef',
        is         => 'ro',
        auto_deref => 1,
        default    => sub { [] },
    );

    has reciever => (
        is      => 'ro',
        default => sub { Receiver->new() },
    );

    sub START {
        my ($self) = @_;
        $self->yield('loop');
    }

    sub on_loop {
        my ($self) = @_;
        my $func = $self->func;
        $self->$func( $self->args );
    }

    sub send {
        my ( $self, $message ) = @_;
        push @{ $self->reciever->mailbox }, [ $message, \@_ ];
        $self->yield('loop');
    }

}

main();
