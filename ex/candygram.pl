#!/usr/bin/env perl 
$| = 1;

{

    package Candygram;

    sub spawn {
        my ( $self, $func ) = @_;
        return Proc->new( func => $func );
    }

}

{

    package Receiver;
    use Moose;

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
                my $res = $self->handlers->{$state}->( $state, @$args );
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
        $self->$func();
    }

    sub send {
        my ( $self, $message ) = splice @_, 0, 2,;
        push @{ $self->reciever->mailbox }, [ $message, \@_ ];
        $self->yield('loop');
    }

}

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

{

    package main;

    sub proc_func {
        my $r = $_[0]->reciever;
        $r->add_handler( 'land_shark', \&shut_door );
        $r->add_handler( 'candygram',  \&open_door );
        while ( my $res = $r->receive ) {
            print $res;
        }
    }

    sub shut_door {
        return 'Go away ' . $_[0];
    }

    sub open_door {
        return 'Hello ' . $_[0];
    }

    my $proc = Candygram->spawn( \&proc_func );
    $proc->send('land_shark');
    $proc->send('candygram');
    POE::Kernel->run;
}
