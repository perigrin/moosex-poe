#!/usr/bin/perl

use Test::More;

my $cnt = 0;

{
	package Test::DoubleBuild::MXP;

	use MooseX::POE;

	sub BUILD {
		$cnt++;
	}
}

Test::DoubleBuild::MXP->new;

is($cnt, 1, 'BUILD called once');

done_testing();
