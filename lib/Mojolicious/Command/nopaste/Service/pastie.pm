package Mojolicious::Command::nopaste::Service::pastie;
use Mojo::Base 'Mojolicious::Command';

use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);
use Mojo::UserAgent;

has description => 'Post to pastie.org';
has usage       => "usage:";

my %languages = (
    "bash" => "13",
    "c#" => "20",
    "c/c++" => "7",
    "css" => "8",
    "diff" => "5",
    "go" => "21",
    "html (erb / rails)" => "12",
    "html / xml" => "11",
    "java" => "9",
    "javascript" => "10",
    "objective-c/c++" => "1",
    "perl" => "18",
    "php" => "15",
    "plain text" => "6",
    "python" => "16",
    "ruby" => "3",
    "ruby on rails" => "4",
    "sql" => "14",
    # hidden
    "apache" => "22",
    "clojure" => "38",
    "d" => "26",
    "erlang" => "27",
    "fortran" => "28",
    "haskell" => "29",
    "ini" => "35",
    "io" => "24",
    "lisp" => "25",
    "lua" => "23",
    "makefile" => "31",
    "nu" => "36",
    "pascal" => "17",
    "puppet" => "39",
    "scala" => "32",
    "scheme" => "33",
    "smarty" => "34",
    "tex" => "37",
    # aliases
    "sh" => "13",
    "c" => "7",
    "c++" => "7",
    "objective-C" => "1",
    "objective-C++" => "1",
    "plain" => "6",
    "raw" => "6",
    "rails" => "4",
    "html" => "11",
    "xml" => "11",
    "js" => "10",
    "make" => "31",
);

sub run {
  my ($self, @args) = @_;
  GetOptionsFromArray \@args,
    'l|lang=s'  => \my $lang,
    'P|private' => \(my $priv = 0);
  my $lang_id = $languages{lc($lang)} || $languages{"plain text"};
  my $text = do { local $/; local @ARGV = @args; <> };

  my $ua = Mojo::UserAgent->new->max_redirects(10);
  my $tx = $ua->post( 'http://pastie.org/pastes', form => {
    'paste[body]'          => $text,
    'paste[authorization]' => 'burger',  # set with JS to avoid bots
    'paste[restricted]'    => $priv,
    'paste[parser_id]'     => $lang_id,
  });

  unless ($tx->res->is_status_class(200)) {
    say $tx->res->message;
    say $tx->res->body;
    exit 1;
  }
  my $prefix = ''; 
  my $title = $tx->res->dom('title')->text;
  my ($id) = $title =~ /\#(\d+)/;
  say "http://pastie.org/$prefix$id"
}
