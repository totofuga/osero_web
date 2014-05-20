use strict;
use warnings;

use Test::More;

BEGIN { use_ok 'Osero::Model::Evaluate' }

use aliased 'Osero::Model::Evaluate';
use Test::MockObject;


my $mock_edgi_ai     = Test::MockObject->new();
$mock_edgi_ai->set_always('evaluate', 1 );

my $mock_fixed_ai    = Test::MockObject->new();
$mock_fixed_ai->set_always('evaluate', 10 );

my $mock_openrate_ai = Test::MockObject->new();
$mock_openrate_ai->set_always('evaluate', 100 );


my $evaluater = new_ok( 'Osero::Model::Evaluate', 
    [{
        edge_ai     => $mock_edgi_ai,
        fixed_ai    => $mock_fixed_ai,
        openrate_ai => $mock_openrate_ai,
    }]
);

is ( 
    $evaluater->evaluate(undef, undef), 

    1   * Evaluate->EDGE_FACTOR()  +
    10  * Evaluate->FIXED_FACTOR() +
    100 * Evaluate->OPENRATE_FACTOR(),
);

done_testing();
