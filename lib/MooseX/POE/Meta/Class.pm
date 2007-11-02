package MooseX::POE::Meta::Class;
use Moose;
extends qw(MooseX::Async::Meta::Class);

sub initialize {
    my $class = shift;
    my $pkg   = shift;
    $class->SUPER::initialize(
        $pkg,
        'instance_metaclass' => 'MooseX::POE::Meta::Instance',
        @_
    );
}

no Moose;
1;
