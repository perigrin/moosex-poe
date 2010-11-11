#!/usr/bin/perl

use Test::More;

my $right_cnt = 0;
my $inside_cnt = 0;
my $outside_cnt = 0;
my $wrong_cnt = 0;

{
	package Test::MooseX::POE::Timers::Doer;

	use MooseX::POE;
	
	event 'tick' => sub {
		my ( $self ) = @_;
		$right_cnt++;
		$self->inside_self_delay;
	};

	event 'inside_self_delay_tick' => sub {
		my ( $self ) = @_;
		$inside_cnt++;
	};

	event 'outside_self_delay_tick' => sub {
		my ( $self ) = @_;
		$outside_cnt++;
	};

	sub inside_self_delay {
		my ( $self ) = @_;
		$self->delay( 'inside_self_delay_tick' => 1 );
	}

	sub outside_self_delay {
		my ( $self ) = @_;
		$self->delay( 'outside_self_delay_tick' => 1 );
	}

}

{
	package Test::MooseX::POE::Timers::SomeoneElse;

	use MooseX::POE;

	sub START {
		my ( $self ) = @_;
		my $doer = Test::MooseX::POE::Timers::Doer->new();
		$doer->delay( 'tick' => 1 );
		$doer->outside_self_delay;
	}
	
	event 'tick' => sub {
		$wrong_cnt++;
	};
}

Test::MooseX::POE::Timers::SomeoneElse->new;
POE::Kernel->run;

is($inside_cnt, 1, 'right self_tick is called by $self inside the session');
is($outside_cnt, 1, 'right self_tick is called by $self outside the session');
is($right_cnt, 1, 'right tick is called');
is($wrong_cnt, 0, 'wrong tick isnt called');

done_testing();
