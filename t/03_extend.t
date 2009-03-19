use strict;
use Test::More tests => 6;

my ($base_start_called, $extended_start_called);
{
  package Base;
  use MooseX::POE;

  sub START { 
    # Do this rather than embedd ::ok(1) here so ath get proper failing reports
    ::pass('Base Start');
    $base_start_called = 1;
  };

  sub on_foo {
    ::pass('on_foo');
    $_[KERNEL]->yield('bar');
  }
}
{
  package Extended;
  use MooseX::POE;

  extends 'Base';

  sub START {
    ::pass('Extended after Start');
    $extended_start_called = 1;
    $_[KERNEL]->yield('foo');
  };

  sub on_bar {
    ::pass('on_bar');
  }
}

my $foo = Extended->new();
POE::Kernel->run();

# If the test count for this test is wrong, on_foo probably isn't getting set
# as an event properly

ok($base_start_called, "Base START called");
ok($extended_start_called,"Extended START called");
