package Mojolicious::Command::nopaste::Service::mathbin;
use Mojo::Base 'Mojolicious::Command::nopaste::Service';

has description => 'Post to mathb.in';
has usage => 'usage:';

sub paste {
  my $self = shift;

  my $name  = $self->name;
  my $title = $self->description;

  my $tx = $self->ua->post( 'http://mathb.in' => form => {
    code    => $self->slurp,
    ( $name  ? ( name  => $name  ) : () ),
    secrecy => $self->private ? 'yes' : '',
    ( $title ? ( title => $title ) : () ),
  });

  unless ($tx->res->is_status_class(200)) {
    say $tx->res->message;
    say $tx->res->body;
    exit 1;
  }

  return $tx->req->url;
}

1;

