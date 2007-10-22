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
    die 'no file' unless -e 'ex/tbray.data';
    Slurp->new( filename => 'ex/tbray.data' );
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

    my $file;

    sub START {
        $file ||= IO::File->new( $_[0]->filename, 'r' );
        shift->yield('loop');
    }

    sub on_loop {
        my ($self) = @_;
        if ( not eof $file ) {
            my @chunk;
            push @chunk, <$file> for ( 0 .. 1 );
            Count->new->yield( 'loop', \@chunk );
            return;
        }
        $self->yield('tally');
    }

    sub on_inc {
        my $chunk = $_[ARG0];
        my $count = $_[0]->count;
        for ( keys %$chunk ) {
            $count->{$_} += $chunk->{$_};
        }
        $_[0]->count($count);
    }

    sub on_tally {
        my $count = $_[OBJECT]->count;

        print "$count->{$_}: $_"
          for sort { $count->{$b} <=> $count->{$a} } keys %$count;
    }

}

{

    package Count;
    use MooseX::POE;

    sub on_loop {
        warn 'loop';
        my ( $self, $sender, $chunk ) = @_[ OBJECT, SENDER, ARG0 ];
        my $count = {};
        for my $line (@$chunk) {
            $count->{$1}++
              if $line =~
              qr|GET /ongoing/When/\d\d\dx/(\d\d\d\d/\d\d/\d\d/[^ .]+)|o;
        }
        POE::Kernel->post( $sender => 'inc', $count );
        POE::Kernel->post( $sender => 'loop' );
    }

}

main();
