package Net::Pachube;

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

=head1 METHODS

=cut

use 5.006;
use strict;
use warnings;
use Carp;
use LWP::UserAgent;
use HTTP::Request;
use Net::Pachube::Response;

require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = '0.01';

=head2 C<new(%params)>

The constructor creates a new L<Net:Pachube> object.  The constructor
takes a parameter hash as arguments.  Valid parameters in the hash
are:

=over

=item feed

  The feed id to use.  This option is necessary for most methods to
  work.

=item key

  The Pachube API key to use.  This parameter is optional.  If it is
  not provided then the value of the environment variable
  C<PACHUBE_API_KEY> is used.

=item pachube_url

  The base URL to use for all HTTP requests.  The default is
  C<http://www.pachube.com/api>.

=item user_agent

  The L<LWP> user agent object to use for all HTTP requests.  The
  default is to create a new one for each new L<Net::Pachube> object.

=back

=cut

sub new {
  my $pkg = shift;
  bless {
         pachube_url => 'http://www.pachube.com/api',
         user_agent => LWP::UserAgent->new(),
         key => $ENV{PACHUBE_API_KEY},
         @_,
        }, $pkg;
}

=head2 C<feed( [$new_feed] )>

This method is an accessor/setter for the C<feed> attribute which is
the feed id to use.

=cut

sub feed {
  $_[0]->{'feed'} = $_[1] if (@_ > 1);
  $_[0]->{'feed'};
}

=head2 C<key( [$new_key] )>

This method is an accessor/setter for the C<key> attribute which is
the Pachube API key to use.

=cut

sub key {
  $_[0]->{'key'} = $_[1] if (@_ > 1);
  $_[0]->{'key'};
}

=head2 C<pachube_url( [$new_url] )>

This method is an accessor/setter for the C<pachube_url> attribute
which is the base URL to to use for all HTTP requests.

=cut

sub pachube_url {
  $_[0]->{'pachube_url'} = $_[1] if (@_ > 1);
  $_[0]->{'pachube_url'};
}

=head2 C<user_agent( [$new_user_agent] )>

This method is an accessor/setter for the C<user_agent> attribute
which is the L<LWP> user agent object to use for all HTTP requests.

=cut

sub user_agent {
  $_[0]->{'user_agent'} = $_[1] if (@_ > 1);
  $_[0]->{'user_agent'};
}

=head2 C<feed_url( )>

This method returns the URL for the XML for the feed.

=cut

sub feed_url {
  $_[0]->pachube_url.'/'.$_[0]->feed.'.xml';
}

=head2 C<feed_csv( )>

This method returns the URL for the CSV for the feed.

=cut

sub feed_csv {
  $_[0]->pachube_url.'/'.$_[0]->feed.'.csv';
}

=head2 C<get( )>

This method returns a L<Net::Pachube::Response> object representing
the result of attempting to obtain the data for the feed.

=cut

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
  Net::Pachube::Response->new(http_response => $ua->request($request));
}

=head2 C<put( @data_values )>

This method returns a L<Net::Pachube::Response> object representing
the result of attempting to C<PUT> data to update the feed.

=cut

sub put {
  my ($self) = shift;
  my $key = $self->key or
    croak(q{No pachube api key defined.
Set PACHUBE_API_KEY environment variable or pass 'key' parameter to the
constructor.
});
  my $ua = $self->user_agent;
  $ua->default_header('X-PachubeApiKey' => $key);
  my $url = $self->feed_csv;
  my $request = HTTP::Request->new('PUT' => $url);
  $request->content(join ',', @_);
  Net::Pachube::Response->new(http_response => $ua->request($request));
}

1;
__END__

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
