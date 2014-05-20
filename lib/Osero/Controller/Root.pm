package Osero::Controller::Root;
use Moose;
use namespace::autoclean;
use Game::Osero;
use Game::Osero::AI::Fixed;
use Game::Osero::AI::Openrate;
use Game::Osero::AI::Edge;

use Osero::Model::Evaluate;
use Game::Osero::AI::MinMax;

use Devel::NYTProf;

use Clone qw(clone);

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=encoding utf-8

=head1 NAME

Osero::Controller::Root - Root Controller for Osero

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->log->debug('Osero Calc Start');

    # Hello World
    # $c->response->body( $c->welcome_message );
    my $osero = Game::Osero->new();

    if ( $c->req->method eq 'POST' ) {
        my $params = $c->req->body_params;

        for my $x (1.. 6) {
            for my $y (1.. 6) {
                $osero->get_openrate()->[$x][$y] = 8;
            }
        }

        my $board = [];
        foreach my $key ( keys %$params ) {
            if ( my @a = ($key =~ /(\d):(\d)/) ) {
                my $x = $a[0] - 1;
                my $y = $a[1] - 1;
                $board->[$x][$y] = $params->{$key};

                if ( $params->{$key} != Game::Osero::BLANK() ) {
                    $osero->drop_openrate($x, $y);
                }
            }
        }

        $osero->set_board($board);

        if( exists $params->{turn} ) {
            $osero->set_turn($params->{turn});
        }

        if( exists $params->{now_pos} ) {
            my $pos = $params->{now_pos};
            if ( my @a = ($pos =~ /(\d):(\d)/) ) {
                $osero->drop($a[0] -1 , $a[1] -1);
            }
        }

        $osero->set_turn($osero->get_rival_turn);

        $self->drop_com($c, $osero);
    }

    my $openrate = Game::Osero::AI::Openrate->new();
    print $osero->get_turn() == Game::Osero::BLACK ? 'black' : 'white';
    print "\n";

    for my $x (0.. 7) {
        for my $y (0.. 7) {
            print $osero->get_board()->[$x][$y];
        }
        print "\n";
    }
    print "osero openrate evaluate :" . $openrate->evaluate($osero, $osero->get_turn). "\n";

    $c->stash()->{osero} = $osero;
    $c->forward( $c->view('HTML') );
}

sub drop_com {
    my ($self, $c, $osero) = @_;

    my $can_drop_pos = $osero->get_can_drop_pos;


    if ( @$can_drop_pos ) {

        my $evaluater = Osero::Model::Evaluate->new({ 
            edge_ai      => Game::Osero::AI::Edge->new(),
            fixed_ai     => Game::Osero::AI::Fixed->new(),
            openrate_ai  => Game::Osero::AI::Openrate->new(),
        });

        my $minmax = Game::Osero::AI::MinMax->new({
            evaluate => $evaluater,
        });

        my $color = $osero->get_turn;

        my $max_evaluate_value;
        my $max_evaluate_pos;
        foreach my $pos (@$can_drop_pos) {

            my $calc_osero = clone $osero;
            $calc_osero->drop($pos->[0], $pos->[1]);
            $calc_osero->set_turn($calc_osero->get_rival_turn);

            my $evaluate_value = $minmax->min_level(3, $calc_osero, $color);

            if ( !defined $max_evaluate_pos || ( $max_evaluate_value < $evaluate_value )) {
                $max_evaluate_value = $evaluate_value;
                $max_evaluate_pos   = $pos;
            }
        }

        $osero->drop($max_evaluate_pos->[0], $max_evaluate_pos->[1]);


    } else {
        $c->stash->{mess} = "コンピュータはパスしました。\n"
    }

    $osero->set_turn($osero->get_rival_turn);
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
