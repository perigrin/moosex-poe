# Load the Module::Install bundled in ./inc/
use inc::Module::Install 0.75;

# Define metadata
name 'MooseX-POE';
all_from 'lib/MooseX/POE.pm';

# Specific dependencies
requires 'Moose'           => '0.56';
requires 'Moose::Exporter' => undef;
requires 'MooseX::Async'   => '0.06';
requires 'POE'             => '0.9999';

build_requires 'Test::More' => '0.42';

no_index 'directory' => 'ex';

sub kwalitee() {
    return <<'END';
use Test::More;
eval "use Test::Kwalitee";
plan skip_all => "Test::Kwalitee not installed; skipping" if $@;
END
}

if ( $ENV{DEVELOPER_TESTS} ) {
    use_test_base;
    use_standard_tests;
    write_test( '000_kwalitee' => kwalitee );
}

WriteAll;
