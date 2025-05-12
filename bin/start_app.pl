#!/usr/bin/env perl
use strict;
use warnings;
use Dancer2;
use DBI;
use File::Spec;
use JSON;

# Initialize SQLite
my $db_file = path(setting('appdir'), 'feedback.db');
my $dbh     = DBI->connect("dbi:SQLite:dbname=$db_file","","",{ RaiseError => 1 });

# Create table if not exists
$dbh->do(q{
  CREATE TABLE IF NOT EXISTS feedback (
    id      INTEGER PRIMARY KEY,
    comment TEXT NOT NULL,
    ts      DATETIME DEFAULT CURRENT_TIMESTAMP
  )
});

# Routes
get '/' => sub {
  template 'feedback', { };
};

post '/' => sub {
  my $comment = body_parameters->get('comment') || '';
  if ( $comment =~ /\S/ ) {
    # Insert into DB
    my $sth = $dbh->prepare("INSERT INTO feedback (comment) VALUES (?)");
    $sth->execute($comment);
    redirect '/thanks';
  }
  else {
    template 'feedback', { error => "Comment cannot be empty.", comment => $comment };
  }
};

get '/thanks' => sub {
  return "<h2>Thanks for your feedback!</h2><p><a href='/'>Back</a></p>";
};

# Mount a route for triggering the daily report manually (for debug)
get '/run-report' => sub {
  # (We'll implement this in Step 3)
  return "Report triggered";
};

# Start the Dancer2 app
dance;
