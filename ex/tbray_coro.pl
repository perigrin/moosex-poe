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
        my ($self) = @_;
        my $file = $self->file;
        while ( my $line = <$file> ) {
            Count->new( sender => $self, chunk => [$line] );
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

}

{

    package Count;
    use MooseX::Coro;

    has sender => (
        isa      => 'Slurp',
        is       => 'ro',
        required => 1
    );

    has chunk => (
        isa        => 'ArrayRef',
        is         => 'ro',
        auto_deref => 1,
        required   => 1,
    );

    sub START {
        $_[0]->yield('loop');
    }

    event loop => sub {
        my ($self) = @_;
        my $count = {};
        for my $line ( $self->chunk ) {
            $count->{$1}++
              if $line =~
              qr|GET /ongoing/When/\d\d\dx/(\d\d\d\d/\d\d/\d\d/[^ .]+)|o;
        }
        $self->sender->yield( 'inc', $count );
    };

}

main();
