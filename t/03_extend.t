use strict;
use Test::More tests => 6;

my ($base_start_called, $extended_start_called);
{
  package Base;
  use MooseX::POE;

  sub START { 
    # Do this rather than embedd ::ok(1) here so ath get proper failing reports
    ::pass('Base Start');
    ::ok(!$extended_start_called, "extended start not called yet");
    $base_start_called = 1;
  };
}
{
  package Extended;
  use MooseX::POE;

  extends 'Base';

  sub START {
    ::ok($base_start_called, "base start already called");
    ::pass('Extended after Start');
    $extended_start_called = 1;
  };
}

my $foo = Extended->new();
POE::Kernel->run();

ok($base_start_called, "Base START called");
ok($extended_start_called,"Extended START called");
