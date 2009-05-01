package Net::Pachube::Response;

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

sub new {
  my $pkg = shift;
  bless {
         @_,
        }, $pkg;
}

sub http_response {
  $_[0]->{'http_response'};
}

sub content {
  $_[0]->http_response->content
}

sub is_success {
  $_[0]->http_response->is_success
}

sub eeml {
  $_[0]->{eeml} or $_[0]->{eeml} = XMLin($_[0]->content);
}

sub title {
  $_[0]->eeml->{environment}->{title};
}

sub description {
  $_[0]->eeml->{environment}->{description};
}

sub id {
  $_[0]->eeml->{environment}->{id};
}

sub status {
  $_[0]->eeml->{environment}->{status};
}

sub feed {
  $_[0]->eeml->{environment}->{feed};
}

sub creator {
  $_[0]->eeml->{environment}->{creator};
}

1;
__END__

=head1 NAME

Net::Pachube::Response - Perl extension for manipulating pachube.com replies

=head1 SYNOPSIS

  # instantiated as result of Net::Pachube request methods
  use Net::Pachube;
  my $feed_id = 1;
  my $pachube = Net::Pachube->new(feed => $feed_id);
  my $response = $pachube->get();

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
