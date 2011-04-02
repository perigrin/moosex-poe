#!/usr/bin/perl

use Test::More;

my $cnt = 0;
my $cnt_start = 0;

{
	package Test::MooseX::POE::DoubleBuild;

	use MooseX::POE;

	sub START {
		$cnt_start++;
	}

	sub BUILD {
		$cnt++;
	}
}

Test::MooseX::POE::DoubleBuild->new;

is($cnt, 1, 'BUILD called once');

is($cnt_start, 0, 'START not called');

POE::Kernel->run;

is($cnt, 1, 'BUILD still called once');

is($cnt_start, 1, 'START called once');

done_testing();