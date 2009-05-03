package Net::Pachube::Response;

=head1 NAME

Net::Pachube::Response - Perl extension for manipulating pachube.com replies

=head1 SYNOPSIS

  # instantiated as result of Net::Pachube request methods
  use Net::Pachube;
  my $feed_id = 1;
  my $pachube = Net::Pachube->new(feed => $feed_id);
  my $response = $pachube->get();

=head1 DESCRIPTION

This module provides encapsulates the results of L<Net::Pachube>
requests.

=head1 METHODS

=cut

use 5.006;
use strict;
use warnings;
use Carp;
use XML::Simple;

require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = '0.01';

=head2 C<new(%params)>

The constructor creates a new L<Net:Pachube::Response> object.  This
method is generally only called by the L<Net::Pachube> request
methods.  The constructor takes a parameter hash as arguments.  Valid
parameters in the hash are:

=over

=item http_response

  The L<LWP> L<HTTP::Response> object for the L<Net::Pachube> request.

=back

=cut

sub new {
  my $pkg = shift;
  bless {
         @_,
        }, $pkg;
}

=head2 C<http_response( )>

This method is an accessor for the C<http_response> attribute which is
the L<LWP> L<HTTP::Response> object for the L<Net::Pachube> request.

=cut

sub http_response {
  $_[0]->{'http_response'};
}

=head2 C<content( )>

This method is shorthand for calling the L<content> method on the
L<http_request> attribute.  It returns the body of the HTTP response -
typically some XML text.

=cut

sub content {
  $_[0]->http_response->content
}

=head2 C<is_success( )>

This method is shorthand for calling the L<is_success> method on the
L<http_request> attribute.  It returns true if the request was
successful.

=cut

sub is_success {
  $_[0]->http_response->is_success
}

=head2 C<eeml( )>

This method returns the L<EEML> from the body of the response if the
request was successful.

=cut

sub eeml {
  $_[0]->{eeml} or $_[0]->{eeml} = XMLin($_[0]->content,
                                         KeyAttr => [qw/id/],
                                         ForceArray => [qw/data/]);
}

=head2 C<title( )>

This method returns the title of the feed from the L<EEML> if the
request was successful.

=cut

sub title {
  $_[0]->eeml->{environment}->{title};
}

=head2 C<description( )>

This method returns the description of the feed from the L<EEML> if the
request was successful.

=cut

sub description {
  $_[0]->eeml->{environment}->{description};
}

=head2 C<id( )>

This method returns the id of the feed from the L<EEML> if the request
was successful.

=cut

sub id {
  $_[0]->eeml->{environment}->{id};
}

=head2 C<status( )>

This method returns the status of the feed from the L<EEML> if the request
was successful.

=cut

sub status {
  $_[0]->eeml->{environment}->{status};
}

=head2 C<feed( )>

This method returns the URL for the feed from the L<EEML> if the
request was successful.

=cut

sub feed {
  $_[0]->eeml->{environment}->{feed};
}

=head2 C<creator( )>

This method returns the creator value from the L<EEML> if the request
was successful.

=cut

sub creator {
  $_[0]->eeml->{environment}->{creator};
}

=head2 C<location( [ $key ] )>

This method returns the location information from the L<EEML> if the
request was successful.  If the optional C<key> parameter is not
supplied then a hash reference will be returned.  If the optional
C<key> parameter is supplied then the value for that key from the hash
is returned.

=cut

sub location {
  defined $_[1] ? $_[0]->eeml->{environment}->{location}->{$_[1]} :
    $_[0]->eeml->{environment}->{location};
}

=head2 C<data( [ $index ] )>

This method returns the value from the data element from the L<EEML>
if the request was successful.  If the optional zero-based C<index>
parameter is not provided, it is assumed to be zero.

=cut

sub data {
  $_[0]->eeml->{environment}->{data}->{$_[1]||0}->{value}->{content};
}

=head2 C<data_min( [ $index ] )>

This method returns the minimum value for the data element from the
L<EEML> if the request was successful.  It may be undefined.  If the
optional zero-based C<index> parameter is not provided, it is assumed
to be zero.

=cut

sub data_min {
  $_[0]->eeml->{environment}->{data}->{$_[1]||0}->{value}->{minValue};
}

=head2 C<data_max( [ $index ] )>

This method returns the maximum value for the data element from the
L<EEML> if the request was successful.  It may be undefined.  If the
optional zero-based C<index> parameter is not provided, it is assumed
to be zero.

=cut

sub data_max {
  $_[0]->eeml->{environment}->{data}->{$_[1]||0}->{value}->{maxValue};
}

=head2 C<data_tag( [ $index ] )>

This method returns the tag value for the data element from the
L<EEML> if the request was successful.  It may be undefined, a
singleton or a list reference if there are multiple tags.  If the
optional zero-based C<index> parameter is not provided, it is assumed
to be zero.

=cut

sub data_tag {
  $_[0]->eeml->{environment}->{data}->{$_[1]||0}->{tag};
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
