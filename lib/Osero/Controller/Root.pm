package Osero::Controller::Root;
use Moose;
use namespace::autoclean;
use Game::Osero;

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

    # Hello World
    # $c->response->body( $c->welcome_message );
    my $osero = Game::Osero->new();

    if ( $c->req->method eq 'POST' ) {
        my $params = $c->req->body_params;

        my $board = [];
        foreach my $key ( keys %$params ) {
            if ( my @a = ($key =~ /(\d):(\d)/) ) {
                $board->[$a[0] - 1][$a[1] - 1] = $params->{$key};
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

    $c->stash()->{osero} = $osero;
    $c->forward( $c->view('HTML') );
}

sub drop_com {
    my ($self, $c, $osero) = @_;

    my $can_drop_pos = $osero->get_can_drop_pos;

    if(@$can_drop_pos) {
        my $rand_pos = $can_drop_pos->[ rand @$can_drop_pos ];
        $osero->drop($rand_pos->[0] , $rand_pos->[1]);
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
