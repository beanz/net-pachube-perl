use strict;
use warnings;
package Net::Pachube::Feed;

# ABSTRACT: Perl extension for manipulating pachube.com feeds

=head1 SYNOPSIS

  # normally instantiated using:

  use Net::Pachube;
  my $pachube = Net::Pachube->new();
  my $feed = $pachube->feed($feed_id);
  print $feed->title, " ", $feed->status, "\n";
  foreach my $i (0..$feed->number_of_streams-1) {
    print "Stream ", $i, " value: ", $feed->data_value($i), "\n";
    foreach my $tag ($feed->data_tags($i)) {
      print "  Tag: ", $tag, "\n";
    }
  }

  # update several streams at once
  $feed->update(data => [0,1,2,3,4]);

  # update one stream
  $feed->update(data => 99);

=head1 DESCRIPTION

This module encapsulates a www.pachube.com feed.

=cut

use 5.006;
use base qw/Class::Accessor::Fast/;
use Carp;
use XML::Simple;

__PACKAGE__->mk_accessors(qw/id pachube eeml/);

=method C<new( %parameters )>

The constructor creates a new L<Net:Pachube::Feed> object.  This
method is generally only called by the L<Net::Pachube> request
methods.  The constructor takes a parameter hash as arguments.  Valid
parameters in the hash are:

=over

=item id

  The id of the feed.

=item pachube

  The L<Net::Pachube> connection object.

=back

=cut

sub new {
  my $pkg = shift;
  my %p = @_;
  my $self = $pkg->SUPER::new(\%p);
  $p{fetch} ? $self->get() : $self;
}

=method C<get( )>

This method refreshes the contents of the feed by sending a C<GET>
request to the server.  It is automatically called when the feed
is created but may be called again to refresh the feed data.

=cut

sub get {
  my ($self) = @_;
  my $pachube = $self->pachube;
  my $url = $pachube->url.'/'.$self->id.'.xml';
  my $resp = $pachube->_request(method => 'GET', url => $url) or return;
  $self->{eeml} = $resp->content;
  $self->{_hash} = XMLin($self->{eeml},
                         KeyAttr => [qw/id/],
                         ForceArray => [qw/data/]);
  return $self;
}

=method C<eeml( )>

This method returns the L<EEML> of the feed.

=method C<title( )>

This method returns the title of the feed from the L<EEML> if the
request was successful.

=cut

sub title {
  $_[0]->{_hash}->{environment}->{title};
}

=method C<description( )>

This method returns the description of the feed from the L<EEML> if the
request was successful.

=cut

sub description {
  $_[0]->{_hash}->{environment}->{description};
}

=method C<feed_id( )>

This method returns the id of the feed from the L<EEML> if the request
was successful.  It should always be equal to C<< $self->id >> which is
used to request the feed data.

=cut

sub feed_id {
  $_[0]->{_hash}->{environment}->{id};
}

=method C<status( )>

This method returns the status of the feed from the L<EEML> if the request
was successful.

=cut

sub status {
  $_[0]->{_hash}->{environment}->{status};
}

=method C<feed_url( )>

This method returns the URL for the feed from the L<EEML> if the
request was successful.

=cut

sub feed_url {
  $_[0]->{_hash}->{environment}->{feed};
}

=method C<creator( )>

This method returns the creator value from the L<EEML> if the request
was successful.

=cut

sub creator {
  $_[0]->{_hash}->{environment}->{creator};
}

=method C<location( [ $key ] )>

This method returns the location information from the L<EEML> if the
request was successful.  If the optional C<key> parameter is not
supplied then a hash reference will be returned.  If the optional
C<key> parameter is supplied then the value for that key from the hash
is returned.

=cut

sub location {
  defined $_[1] ? $_[0]->{_hash}->{environment}->{location}->{$_[1]} :
    $_[0]->{_hash}->{environment}->{location};
}

=method C<number_of_streams( )>

This method returns the number of data streams present in the feed.

=cut

sub number_of_streams {
  scalar keys %{$_[0]->{_hash}->{environment}->{data}}
}

=method C<data_value( [ $index ] )>

This method returns the value from the data stream from the L<EEML>
if the request was successful.  If the optional zero-based C<index>
parameter is not provided, it is assumed to be zero.

=cut

sub data_value {
  $_[0]->{_hash}->{environment}->{data}->{$_[1]||0}->{value}->{content};
}

=method C<data_min( [ $index ] )>

This method returns the minimum value for the data stream from the
L<EEML> if the request was successful.  It may be undefined.  If the
optional zero-based C<index> parameter is not provided, it is assumed
to be zero.

=cut

sub data_min {
  $_[0]->{_hash}->{environment}->{data}->{$_[1]||0}->{value}->{minValue};
}

=method C<data_max( [ $index ] )>

This method returns the maximum value for the data stream from the
L<EEML> if the request was successful.  It may be undefined.  If the
optional zero-based C<index> parameter is not provided, it is assumed
to be zero.

=cut

sub data_max {
  $_[0]->{_hash}->{environment}->{data}->{$_[1]||0}->{value}->{maxValue};
}

=method C<data_tags( [ $index ] )>

This method returns the tag value for the data stream from the L<EEML>
if the request was successful.  It may be undefined or a list of tags.
If the optional zero-based C<index> parameter is not provided, it is
assumed to be zero.

=cut

sub data_tags {
  my $tags = $_[0]->{_hash}->{environment}->{data}->{$_[1]||0}->{tag} or return;
  ref $tags ? @$tags : $tags
}

=method C<<update( data => \@data_values )>>

This method performs a C<PUT> request in order to update a feed.
It returns true on success or undef otherwise.

=cut

sub update {
  my ($self) = shift;
  my %p = @_;
  my $pachube = $self->pachube;
  my $url = $pachube->url.'/'.$self->id;
  my $data = ref $p{data} ? $p{data} : [$p{data}];
  $pachube->_request(method => 'PUT', url => $url.'.csv',
                     content => (join ',', @$data));
}

=method C<delete( )>

This method sends a C<DELETE> request to the server to remove
it from the server.  It returns true if successful or undef
otherwise.

=cut

sub delete {
  my $self = shift;
  my $pachube = $self->pachube;
  my $url = $pachube->url.'/'.$self->id;
  delete $self->{eeml};
  $pachube->_request(method => 'DELETE', url => $url);
}

1;
__END__

=head1 SEE ALSO

Pachube web site: http://www.pachube.com/
