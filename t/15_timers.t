#!/usr/bin/perl

use Test::More;

my $right_cnt = 0;
my $wrong_cnt = 0;

{
	package Test::MooseX::POE::Timers::Doer;

	use MooseX::POE;
	
	event 'tick' => sub {
		$right_cnt++;
	};
}

{
	package Test::MooseX::POE::Timers::SomeoneElse;

	use MooseX::POE;

	sub START {
		my ( $self ) = @_;
		my $doer = Test::MooseX::POE::Timers::Doer->new();
		$doer->delay( 'tick' => 1 );
	}
	
	event 'tick' => sub {
		$wrong_cnt++;
	};
}

Test::MooseX::POE::Timers::SomeoneElse->new;
POE::Kernel->run;

is($right_cnt, 1, 'right tick is called');
is($wrong_cnt, 0, 'wrong tick isnt called');

done_testing();