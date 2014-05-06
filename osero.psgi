use strict;
use warnings;

use Osero;

my $app = Osero->apply_default_middlewares(Osero->psgi_app);
$app;

