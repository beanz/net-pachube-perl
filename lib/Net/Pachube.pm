package Net::Pachube;

use 5.006;
use strict;
use warnings;
use Carp;
use LWP::UserAgent;
use HTTP::Request;

require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = '0.01';

sub new {
  my $pkg = shift;
  $pkg = ref $pkg if (ref $pkg);
  bless {
         pachube_url => 'http://www.pachube.com/api',
         user_agent => LWP::UserAgent->new(),
         key => $ENV{PACHUBE_API_KEY},
         @_,
        }, $pkg;
}

sub pachube_url {
  $_[0]->{'pachube_url'} = $_[1] if (@_ > 1);
  $_[0]->{'pachube_url'};
}

sub user_agent {
  $_[0]->{'user_agent'} = $_[1] if (@_ > 1);
  $_[0]->{'user_agent'};
}

sub key {
  $_[0]->{'key'} = $_[1] if (@_ > 1);
  $_[0]->{'key'};
}

sub feed {
  $_[0]->{'feed'} = $_[1] if (@_ > 1);
  $_[0]->{'feed'};
}

sub feed_url {
  $_[0]->pachube_url.'/'.$_[0]->feed.'.xml';
}

sub get {
  my ($self) = @_;
  my $key = $self->key or
    croak(q{No pachube api key defined.
Set PACHUBE_API_KEY environment variable or pass 'key' parameter to the
constructor.
});
  my $ua = $self->user_agent;
  $ua->default_header('X-PachubeApiKey' => $key);
  my $url = $self->feed_url;
  my $request = HTTP::Request->new('GET' => $url);
  my $resp = $ua->request($request);
  unless ($resp->is_success) {
    croak "Get failed response was '", $resp->status_line, "'\n",
      $resp->content;
  }
  return $resp->content;
}

1;
__END__

=head1 NAME

Net::Pachube - Perl extension for manipulating pachube.com feeds

=head1 SYNOPSIS

  use Net::Pachube;
  my $feed_id = 1;
  my $pachube = Net::Pachube->new(feed => $feed_id);
  my $eeml = $pachube->get();
  $pachube->put(data => 99);
  $pachube->put(data => [0,1,2,3,4]);

=head1 DESCRIPTION

This module provides a simple API to fetch and/or update pachube.com
feeds.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Pachube web site: http://www.pachube.com/

=head1 AUTHOR

Mark Hindess, E<lt>soft-pachube@temporalanomaly.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Mark Hindess

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
