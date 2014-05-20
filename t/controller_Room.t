use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Osero';
use Osero::Controller::Room;

ok( request('/room')->is_success, 'Request should succeed' );

my $req = request('/room/list');

done_testing();
