#!/usr/bin/env perl -l

###
### THIS SCRIPT DOES NOT WORK
###
### I suspect that Coro and MX::Workers won't play nice, but
### it will have to wait till later for me to debug it
###

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
}

{

    package Slurp;
    use MooseX::Coro;
    use IO::File;
    use Coro;
    has filename => (
        isa => 'Str',
        is  => 'ro',
    );

    has count => (
        isa     => 'HashRef',
        is      => 'rw',
        default => sub { {} },
    );

    has file => (
        isa     => 'IO::File',
        is      => 'ro',
        lazy    => 1,
        default => sub { IO::File->new( $_[0]->filename, 'r' ); },
    );

    has counter => (
        reader  => 'c',
        default => sub { Count->new( sender => $_[0] ) },
        handles => { counter => 'yield' },
    );

    sub START {
        $_[0]->yield('loop');
    }

    event loop => sub {
        my ($self) = @_;
        my $file = $self->file;

        while ( not eof $file ) {
            my @chunk;
            for ( 0 .. ( 600000 / 8 ) ) {
                $_ = <$file>;
                push @chunk, $_;
            }
            $self->counter( 'loop', $self, \@chunk );
        }
        $self->yield('tally');
    };

    event inc => sub {
        my ( $self, $chunk ) = @_;
        my $count = $self->count;
        $count->{$_} += $chunk->{$_} for ( keys %$chunk );
        $_[0]->count($count);
    };

    event tally => sub {
        my $count = $_[0]->count;

        print "$count->{$_}: $_"
          for sort { $count->{$b} <=> $count->{$a} } keys %$count;

        $_[0]->yield('STOP');
    };
    __PACKAGE__->meta->make_immutable;
}

{

    package Count;
    use MooseX::Coro;
    use JSON::Any qw(XS);
    with qw(MooseX::Workers);

    sub BUILD { POE::Kernel->run }

    has sender => (
        reader   => 's',
        required => 1,
        handles  => { sender => 'yield' },
    );

    event loop => sub {
        my ( $self, $chunk ) = @_;
        my $count = {};
        my $rx    = qr|GET /ongoing/When/\d\d\dx/(\d\d\d\d/\d\d/\d\d/[^ .]+)|o;
        $self->spawn(
            sub {
                for my $line (@$chunk) {
                    $count->{$1}++ if $line =~ $rx;
                }
                print JSON::Any->encode($count);
            }
        );
    };

    sub worker_stdout {
        my ( $self, $out ) = @_;
        warn $out;
        my $count = JSON::Any->decode($out);
        $self->sender_return( 'inc', $count );
    }

    sub worker_manager_start { warn 'started worker manager' }
    sub worker_manager_stop  { warn 'stopped worker manager' }
    sub max_workers_reached  { warn 'maximum worker count reached' }

    sub worker_stderr { shift; warn 'STDERR: ' . join ' ', @_; }
    sub worker_error { shift; warn join ' ', @_; }
    sub worker_done    { shift; warn 'DONE: ' . join ' ',    @_; }
    sub worker_started { shift; warn 'STARTED: ' . join ' ', @_; }
    sub sig_child { shift; warn join ' ', @_; }

    __PACKAGE__->meta->make_immutable;
}

main();
