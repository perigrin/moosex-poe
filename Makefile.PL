# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name 'MooseX-POE';
all_from 'lib/MooseX/POE.pm';

# Specific dependencies
requires 'Moose'         => '0.26';
requires 'POE'           => '0.9999';
requires 'Sub::Name'     => undef;
requires 'Sub::Exporter' => undef;

build_requires 'Test::More' => '0.42';

no_index 'directory' => 'ex';

auto_install;
WriteAll;
