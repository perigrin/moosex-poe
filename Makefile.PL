# Load the Module::Install bundled in ./inc/
use inc::Module::Install 0.77;

# Define metadata
name 'MooseX-POE';
all_from 'lib/MooseX/POE.pm';

# Specific dependencies
requires 'Moose'         => '0.26';
requires 'MooseX::Async' => '0.01';
requires 'POE'           => '0.9999';
requires 'Sub::Name'     => '0.04';
requires 'Sub::Exporter' => '0.981';

build_requires 'Test::More' => '0.42';

no_index 'directory' => 'ex';

auto_install;
WriteAll;
