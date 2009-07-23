#!/usr/bin/env perl -l
use strict;

my $count         = 0;
my $max_sessions  = 800;
my $half_sessions = int( $max_sessions / 2 );

my %english = (
    lose   => 'is losing',
    gain   => 'is gaining',
    create => 'has created'
);

# this is based on the forkbomb.perl example that comes with POE
# please check it out for better documentation

{

    package ForkBomber;
    use MooseX::POE;

    has id => (
        isa     => 'Str',
        is      => 'ro',
        default => sub { $count++ },
    );

    sub START {
        $_[0]->yield('fork');
        $poe_kernel->sig( 'INT',    'on_signal_handler' );
        $poe_kernel->sig( 'ZOMBIE', 'on_signal_handler' );

        print 'Started  ' . $_[0]->id;
    }

    sub STOP {
        print 'stopped ' . $_[OBJECT]->id;
    }

    sub CHILD {
        my ( $kernel, $self, $direction, $child, $return ) =
          @_[ KERNEL, OBJECT, ARG0, ARG1, ARG2 ];

        print printf(
            "%4d %s child %s%s\n",
            $self->id,
            $english{$direction},
            $kernel->call( $child, 'on_fetch_id' ),
            (
                ( $direction eq 'create' ) ? (" (child returned: $return)") : ''
            )
        );
    }

    sub PARENT {
        my ( $kernel, $self, $old_parent, $new_parent ) =
          @_[ KERNEL, OBJECT, ARG0, ARG1 ];
        print printf(
            "%4d parent is changing from %d to %d\n",
            $self->id,
            $poe_kernel->call( $old_parent, 'on_fetch_id' ),
            $poe_kernel->call( $new_parent, 'on_fetch_id' )
        );
    }

    event signal_handler => sub {
        my ( $self, $signal_name ) = @_[ OBJECT, ARG0 ];
        print printf( "%4d has received SIG%s\n", $self->id, $signal_name );

        # tell Kernel that this wasn't handled
        return 0;
    };

    event fork => sub {
        my ( $kernel, $self ) = @_[ KERNEL, OBJECT ];

        if ( $count < $max_sessions ) {

            if ( rand() < 0.5 ) {
                print $self->id . " is starting a new child...";
                ForkBomber->new;
            }

            # tails == don't spawn
            else {
                print $self->id . " is just spinning its wheels this time...";
            }

            if ( ( $count < $half_sessions ) || ( rand() < 0.05 ) ) {
                $poe_kernel->yield('fork');
            }
            else {
                print $self->id . " has decided to die.  Bye!";
                if ( $self->id != 1 ) {
                    $poe_kernel->yield('_stop');
                }
            }
        }
        else {
            print $self->id . " notes that the session limit is met.  Bye!";

            # Please see the two NOTEs above.

            if ( $self->id != 1 ) {
                $poe_kernel->yield('_stop');
            }
        }
    };

    event fetch_id => sub {
        return $_[OBJECT]->id;
    }

}

ForkBomber->new;
POE::Kernel->run;
__END__
