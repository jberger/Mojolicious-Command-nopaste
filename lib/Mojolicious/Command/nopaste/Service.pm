package Mojolicious::Command::nopaste::Service;
use Mojo::Base 'Mojolicious::Command';

use Mojo::UserAgent;
use Mojo::Util 'monkey_patch';
use Getopt::Long qw(GetOptionsFromArray :config no_ignore_case); # no_auto_abbrev

has [qw/chan name description/];
has clip => sub { 
  die "Clipboard module not available. Do you need to install it?\n"
    unless eval 'use Clipboard; 1';
  monkey_patch 'Clipboard::Xclip' => copy => sub {
    my ($self, $input) = @_;
    eval { $self->copy_to_selection($_, $input) } for $self->all_selections();
  };
  return 'Clipboard';
};
has copy     => 0;
has files    => sub { [] };
has language => 'perl';
has open     => 0;
has private  => 0;
has text     => sub { shift->slurp };
has ua       => sub { Mojo::UserAgent->new->max_redirects(10) };

sub run {
  my ($self, @args) = @_;
  GetOptionsFromArray( \@args,
    'chan|c=s'        => sub { $self->chan($_[1])              },
    'copy|x'          => sub { $self->copy($_[1])              },
    'description|d=s' => sub { $self->description($_[1])       },
    'name|n=s'        => sub { $self->name($_[1])              },
    'language|l=s'    => sub { $self->language($_[1])          },
    'open|o'          => sub { $self->open($_[1])              },
    'paste|p'         => sub { $self->text($self->clip->paste) },
    'private|P'       => sub { $self->private($_[1])           },
  );
  $self->files(\@args);
  my $url = $self->paste or return;
  say $url;
  $self->clip->copy($url) if $self->copy;
  if ($self->open) {
    die "Browser::Open module not available. Do you need to install it?\n?"
      unless eval { require Browser::Open; 1 };
    Browser::Open::open_browser($url);
  }
}

sub paste { die 'Not implemented' }

sub slurp { 
  my ($self, @files) = @_;
  @files = @{ $self->files } unless @files;
  local $/; 
  local @ARGV = @files; 
  <>; 
}



1;

