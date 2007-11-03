#!/usr/bin/env perl -l

#
# http://www.tbray.org/ongoing/When/200x/2007/09/20/Wide-Finder
#

#
# Rather than Erlang (as was in here before) this is more based on the
# Scala version of this code at
# http://www.martin-probst.com/2007/09/24/wide-finder-in-scala/
#

#
# requires the data at http://www.tbray.org/tmp/o10k.ap
#

$|++;

sub main {
    die 'no file' unless -e 'ex/tbray.data.big';
    Slurp->new( filename => 'ex/tbray.data.big' );
    POE::Kernel->run();
}

{

    package Slurp;
    use MooseX::POE;
    use IO::File;
    has filename => (
        isa => 'Str',
        is  => 'ro',
    );

    has count => (
        isa     => 'HashRef',
        is      => 'rw',
        default => sub { {} },
    );

    has _counter => (
        is      => 'ro',
        lazy    => 1,
        default => sub { Count->new },
        handles => { counter => 'yield', }
    );

    my $file;

    sub START {
        $file ||= IO::File->new( $_[0]->filename, 'r' );
        shift->yield('loop');
    }

    event loop => sub {
        my ($self) = @_;
        if ( not eof $file ) {
            my @chunk;
            for ( 0 .. ( 600000 / 8 ) ) {
                $_ = <$file>;
                push @chunk, $_;
            }
            $self->counter( 'loop', \@chunk );
            return;
        }
        $self->yield('tally');
    };

    event inc => sub {
        my $chunk = $_[ARG0];
        my $count = $_[0]->count;
        for ( keys %$chunk ) {
            $count->{$_} += $chunk->{$_};
        }
        $_[0]->count($count);
    };

    event tally => sub {
        my $count = $_[OBJECT]->count;
        print "$count->{$_}: $_"
          for sort { $count->{$b} <=> $count->{$a} } keys %$count;
    };

}

{

    package Count;
    use MooseX::POE;
    use JSON::Any qw(XS);
    with qw(MooseX::Workers);

    event loop => sub {
        my ( $self, $sender, $chunk ) = @_[ OBJECT, SENDER, ARG0 ];
        my $rx = qr|GET /ongoing/When/\d\d\dx/(\d\d\d\d/\d\d/\d\d/[^ .]+)|o;
        $self->spawn(
            sub {
                Coro::killall;
                my $count = {};
                for my $line (@$chunk) {
                    $count->{$1}++ if $line =~ $rx;
                }
                print JSON::Any->encode(
                    { sender => $sender->ID, count => $count } );
            }
        );
        POE::Kernel->post( $sender => 'loop' );
    };

    sub worker_stdout {
        my ( $self, $out ) = @_;
        my $msg = JSON::Any->decode($out);
        POE::Kernel->post( $msg->{sender} => 'inc' => $msg->{count} );
    }

}

main();
