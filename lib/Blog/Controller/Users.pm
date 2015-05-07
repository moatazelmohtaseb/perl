package Blog::Controller::Users;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head2 list
Fetch all users and pass to the view in
stash to be displayed
=cut
use Digest::MD5 qw(md5_hex);

sub list :Local {
my ($self, $c) = @_;
my @users = $c->model('DB::User')->all;
$c->stash->{users}=\@users;
$c->stash(template => 'users/list.tt');
}

sub base :Chained('/') :PathPart('users') :CaptureArgs(0) {
my ($self, $c) = @_;
# Store the ResultSet in stash so it's available for other methods
$c->stash(resultset => $c->model('DB::User'));
# Print a message to the debug log
$c->log->debug('*** INSIDE BASE METHOD ***');
}

sub form_create :Chained('base') :PathPart('create') :Args(0) {
my ($self, $c) = @_;
# Set the TT template to use
$c->stash(template => 'users/create.tt');
}



sub form_create_do :Chained('base') :PathPart('save') :Args(0) {
my ($self, $c) = @_;
# Retrieve the values from the form
my $username = $c->request->params->{name} || 'N/A';
my $email = $c->request->params->{email} || 'N/A';
my $password= $c->request->params->{password} || 'N/A';

# Create the user
my @users = $c->model('DB::User')->all;
my $user = $c->model('DB::User')->create({
name => $username,
email => $email,
password => md5_hex($password)
});
# Store new model object in stash and set template
$c->stash->{users}=\@users;
$c->stash(user => $user,
template => 'users/show.tt');

}


sub form_create_dos :Chained('object') :PathPart('update') :Args(0) {
my ($self, $c) = @_;
# Retrieve the values from the form
my $username = $c->request->params->{name} || 'N/A';
my $email = $c->request->params->{email} || 'N/A';
my $password= $c->request->params->{password} || 'N/A';



$c->stash->{object}->update({
name => $username,
email => $email,
password => md5_hex($password)
});
# Store new model object in stash and set template

$c->stash(user => $c->stash->{object},
template => 'users/show.tt');

}

sub object :Chained('base') :PathPart('id') :CaptureArgs(1) {
    # $id = primary key of book to delete
    my ($self, $c, $id) = @_;

    # Find the book object and store it in the stash
    $c->stash(object => $c->stash->{resultset}->find($id));

    # Make sure the lookup was successful.  You would probably
    # want to do something like this in a real app:
    #   $c->detach('/error_404') if !$c->stash->{object};
    die "Book $id not found!" if !$c->stash->{object};

    # Print a message to the debug log
    $c->log->debug("*** INSIDE OBJECT METHOD for obj id=$id ***");
}

sub edit :Chained('object') :PathPart('edit') :Args(0) {
    my ($self, $c) = @_;

    # Use the book object saved by 'object' and delete it along
    # with related 'book_author' entries
    $c->stash->{object};

    # Set a status message to be displayed at the top of the view
    $c->stash(
	template => 'users/edit.tt');

}

=head2 delete

Delete a book

=cut

sub delete :Chained('object') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;

    # Use the book object saved by 'object' and delete it along
    # with related 'book_author' entries
    $c->stash->{object}->delete;

    # Set a status message to be displayed at the top of the view
    $c->stash->{status_msg} = "Book deleted.";

    # Forward to the list action/method in this controller
    $c->forward('list');
}

=head1 NAME

Blog::Controller::Users - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Blog::Controller::Users in Users.');
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
