# Load the Module::Install bundled in ./inc/
use inc::Module::Install 0.79;

# Define metadata
name 'MooseX-POE';
all_from 'lib/MooseX/POE.pm';

# Specific dependencies
requires 'Moose'         => '0.73';
requires 'POE'           => '1.004';
requires 'Sub::Name'     => '0.04';

build_requires 'Test::More' => '0.42';

no_index 'directory' => 'ex';

auto_set_repository;
auto_manifest;
WriteAll;
