package Blog::Controller::Posts;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Blog::Controller::Posts - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Blog::Controller::Posts in Posts.');
}

sub list :Local {
my ($self, $c) = @_;
my @users = $c->model('DB::Post')->all;
$c->stash->{users}=\@users;
$c->stash(template => 'posts/list.tt');
}

sub base :Chained('/') :PathPart('posts') :CaptureArgs(0) {
my ($self, $c) = @_;
# Store the ResultSet in stash so it's available for other methods
$c->stash(resultset => $c->model('DB::Post'));
# Print a message to the debug log
$c->log->debug('*** INSIDE BASE METHOD ***');
}

sub object :Chained('base') :PathPart('id') :CaptureArgs(1) {
    # $id = primary key of book to delete
    my ($self, $c, $id) = @_;

    # Find the book object and store it in the stash
    $c->stash(object => $c->stash->{resultset}->find($id));
    my @comments = $c->model('DB::Comment')->search({post_id => $id });
    $c->stash->{comments}=\@comments;
    # Make sure the lookup was successful.  You would probably
    # want to do something like this in a real app:
    #   $c->detach('/error_404') if !$c->stash->{object};
    die "Book $id not found!" if !$c->stash->{object};

    # Print a message to the debug log
    $c->log->debug("*** INSIDE OBJECT METHOD for obj id=$id ***");
}

sub edit :Chained('object') :PathPart('show') :Args(0) {
    my ($self, $c) = @_;

    # Use the book object saved by 'object' and delete it along
    # with related 'book_author' entries
    $c->stash->{object};

    # Set a status message to be displayed at the top of the view
    $c->stash(user => $c->stash->{object},
	template => 'posts/show.tt');

}

sub comment :Chained('object') :PathPart('comment') :Args(0) {
    my ($self, $c) = @_;

    
	my $text = $c->request->params->{text} || 'N/A';
	my $username = $c->request->params->{intent} || 'N/A';
	# Create the user
	
	my $user = $c->model('DB::Comment')->create({
	user_name => $username,
	text => $text,
	post_id => $c->stash->{object}->id
	});
	
    # Set a status message to be displayed at the top of the view
    $c->stash(user => $c->stash->{object},
	template => 'posts/show.tt');

}



=encoding utf8

=head1 AUTHOR

moataz,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
