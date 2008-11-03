#!/usr/bin/env perl
use strict;
use Test::More 'no_plan';

{
  package Counter;
  use MooseX::POE;
  use metaclass 'MooseX::POE::SweetArgs';

  has count => (is => 'rw', default => 1);

  sub START {
    my ($self) = @_;
    $self->yield(add => 5);
  }

  event add => sub {
    my ($self, $n) = @_;
    ::is(scalar @_, 2, 'correct number of args');
    ::is($n, 5, 'got the right value');
    $self->count( $self->count + $n );
  };

  no MooseX::POE;
}

my $counter = Counter->new;
POE::Kernel->run;
is($counter->count, 6, 'correct final count');
