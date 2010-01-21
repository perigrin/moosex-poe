# Load the Module::Install bundled in ./inc/
use inc::Module::Install 0.79;

# Define metadata
name 'MooseX-POE';
all_from 'lib/MooseX/POE.pm';

# Specific dependencies
requires 'Moose'         => '0.90';
requires 'POE'           => '1.004';

build_requires 'Test::More' => '0.90';

no_index 'directory' => 'ex';

if ($ENV{AUTOMATED_TESTING}) {
       include 'Module::AutoInstall';
       auto_install;
}

auto_set_repository;
auto_manifest;
WriteAll;
