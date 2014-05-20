package Osero::Model::Evaluate;

use base qw(Class::Accessor::Fast);
__PACKAGE__->follow_best_practice();
__PACKAGE__->mk_ro_accessors( qw( edge_ai fixed_ai openrate_ai ) );

use constant {
    EDGE_FACTOR     => 100,
    FIXED_FACTOR    => 1,
    OPENRATE_FACTOR => 10,
};

my $cnt;

sub evaluate {
    my ($self, $osero, $color) = @_;

    DB::enable_profile();
    warn "evaluate start". $cnt++ ."\n";
    my $evaluate_value  = $self->get_edge_ai->evaluate($osero, $color)     * EDGE_FACTOR;
    $evaluate_value    += $self->get_fixed_ai->evaluate($osero, $color)    * FIXED_FACTOR;
    $evaluate_value    += $self->get_openrate_ai->evaluate($osero, $color) * OPENRATE_FACTOR;
    DB::disable_profile();

    return $evaluate_value;
}

1;
