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

    sub START {
        $_[0]->yield('loop');
    }

    event loop => sub {
        my ($self)  = @_;
        my $file    = $self->file;
        my $counter = Count->new;
        while ( not eof $file ) {
            my @chunk;
            for ( 0 .. ( 600000 / 2 ) ) {
                $_ = <$file>;
                push @chunk, $_;
            }
            $counter->yield( 'loop', $self, \@chunk );
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
    use Coro::Util;
    use Coro::Semaphore;

    has cpulock => (
        is      => 'ro',
        default => sub { new Coro::Semaphore 2; },
        handles => [qw(guard)],
    );

    my $rx = qr|GET /ongoing/When/\d\d\dx/(\d\d\d\d/\d\d/\d\d/[^ .]+)|o;

    event loop => sub {
        my ( $self, $sender, $chunk ) = @_;
        my $guard = $self->guard;

        ### This doesn't return until after we have exited
        ### this is probably a priority issue but I can't seem to sort it
        ### Coro is a PITA

        my $count = Coro::Util::fork_eval {
            my %count;
            for my $line (@$chunk) {
                next unless $line;
                $count{$1}++ if $line =~ $rx;
            }
            warn 'returning ' . scalar keys %count;
            return \%count;
        };

        warn "Here!";
        $sender->yield( 'inc', $count );
    };

    event run => sub {
        my ( $self, $chunk ) = @_;

    };
    __PACKAGE__->meta->make_immutable;
}

main();
