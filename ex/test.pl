#!/usr/bin/env perl -wls

use Socket;
use IO::Handle;
use POSIX ':sys_wait_h';

BEGIN { $J ||= 1; }

sub spawn(&) {
    my ($proc) = @_;
    my %child;
    for ( 1 .. $J ) {
        socketpair( my $CHILD, my $PARENT, AF_UNIX, SOCK_STREAM, PF_UNSPEC )
          or die "$!";
        map { $_->autoflush(1) } ( $CHILD, $PARENT );
        unless ( my $pid = fork ) {
            die "cannot fork: $!" unless defined $pid;
            close $CHILD;
            $proc->($PARENT);
            close $PARENT;
            exit;
        }
        else {
            close $PARENT;
            $child{$pid} = $CHILD;
        }
    }
    return \%child;
}

my $children = spawn {
    my ($PARENT) = @_;
    while (<$PARENT>) {
        chomp;
        print $PARENT "Child Pid $$ got $_";
    }
};

sub reaper {
    my $pid;
    while ( ( $pid = waitpid( -1, WNOHANG ) ) > 0 ) {
        delete $children->{$pid};
    }
    $SIG{CHLD} = \&reaper;
}
$SIG{CHLD} = \&reaper;

for my $pid ( keys %$children ) {
    my $CHILD = $children->{$pid};
    print $CHILD "Parent Pid $$ is sending this";
    chomp( $line = <$CHILD> );
    print "Parent Pid $$ just read this: `$line'";
    close $CHILD;
}
