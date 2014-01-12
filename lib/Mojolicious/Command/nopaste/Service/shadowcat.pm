package Mojolicious::Command::nopaste::Service::shadowcat;
use Mojo::Base 'Mojolicious::Command::nopaste::Service';

has description => "Post to paste.scsys.co.uk\n";
has usage       => "usage:";

sub paste {
  my $self = shift;
  my $tx = $self->ua->post( 'http://paste.scsys.co.uk/paste' => form => {
    channel => $self->channel || '',
    nick    => $self->name || '',
    paste   => $self->text,
    summary => $self->description || '',
  });

  unless ($tx->res->is_status_class(200)) {
    say $tx->res->message;
    say $tx->res->body;
    exit 1;
  }

  my $url = $tx->res->url;
  $url->query( hl => 'on' ) if $self->language eq 'perl';
  return $url;
}

1;

