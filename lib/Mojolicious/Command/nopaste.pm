package Mojolicious::Command::nopaste;
use Mojo::Base 'Mojolicious::Commands';

has description => "Paste to your favorite pastebin sites.\n";
has hint        => <<EOF;

See '$0 nopaste help SERVICE' for more information on a specific service implementation.
EOF
has message => <<EOF;
usage: $0 nopaste SERVICE [OPTIONS]

These services are currently available:
EOF
has namespaces => sub { ['Mojolicious::Command::nopaste::Service'] };
has usage => "usage: $0 nopaste SERVICE [OPTIONS]\n";

sub help { shift->run(@_) }

1;

