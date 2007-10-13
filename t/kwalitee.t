#!perl

use Test::More;
eval "use Test::Kwalitee";
plan skip_all => "Test::Kwalitee not installed; skipping" if $@;

Test::Perl::Critic::all_critic_ok();
