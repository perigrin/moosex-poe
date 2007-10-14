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

my %count = ();
$|++;

sub main {
    die 'no file' unless -e 'ex/tbray.data';
    Slurp->new( filename => 'ex/tbray.data');
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

    my $file;

    sub START {
        $file ||= IO::File->new( $_[0]->filename, 'r' );
        shift->yield('loop');
    }

    sub on_loop {
        my ($self) = @_;
        if ( defined( my $line = <$file> ) ) {
            Count->new->yield( 'loop', $line );
            $self->yield('loop');
            return;
        }
        $self->yield('tally');
    }

    sub on_inc {
        $count{ $_[ARG0] }++;
    }

    sub on_tally {
        print "$count{$_}: $_"
          for sort { $count{$b} <=> $count{$a} } keys %count;
    }

}

{

    package Count;
    use MooseX::POE;

    sub on_loop {
        my ( $self, $sender, $line ) = @_[ OBJECT, SENDER, ARG0 ];
        POE::Kernel->post( $sender => 'inc', $1 )
          if $line =~ qr|GET /ongoing/When/\d\d\dx/(\d\d\d\d/\d\d/\d\d/[^ .]+)|;
    }

}

main();
