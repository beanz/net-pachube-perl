#!/usr/bin/perl -w
use strict;
use Test::More tests => 11;

use_ok('Net::Pachube');

delete $ENV{PACHUBE_API_KEY}; # ignore users key if any
my $pachube = Net::Pachube->new(feed => 2);
ok($pachube, 'constructor');
is($pachube->feed, 2, 'feed initialized');
is($pachube->feed(1), 1, 'feed set');
is($pachube->feed, 1, 'feed retrieved');
is($pachube->feed_url, 'http://www.pachube.com/api/1.xml', 'feed url');
eval { $pachube->get; };
like($@, qr/^No pachube api key defined\./, 'no key defined');
is($pachube->key('blahblahblah'), 'blahblahblah', 'key set');

my $response;
{
  package MockUA;
  sub new {
    bless {}, 'MockUA';
  }
  sub default_header {
    $_[0]->{default_header} = $_[1];
  }
  sub request {
    $response;
  }
  1;
}
my $ua = MockUA->new;
is($pachube->user_agent($ua), $ua, 'set user_agent to mock object');
$response =  HTTP::Response->new( '401', 'Unauthorized');
eval { $pachube->get(); };
like($@, qr/^Get failed response was '401 Unauthorized'/,
     'not authorized error');
$response =
  HTTP::Response->new('200', 'OK', undef,
                      q{<?xml version="1.0" encoding="UTF-8"?>
<eeml xmlns="http://www.eeml.org/xsd/005" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="5" xsi:schemaLocation="http://www.eeml.org/xsd/005 http://www.eeml.org/xsd/005/005.xsd">
  <environment updated="2009-04-30T22:24:11Z" id="1" creator="http://www.haque.co.uk">
    <title>Temperature</title>
    <feed>http://www.pachube.com/api/1.xml</feed>
    <status>live</status>
    <description>Temperature</description>
    <location domain="physical" exposure="outdoor" disposition="fixed">
      <name>Winchester, UK</name>
      <lat>51.0</lat>
      <lon>-1.3</lon>
    </location>
    <data id="0">
      <tag>temperature</tag>
      <value minValue="0.0" maxValue="34.0">22.3</value>
    </data>
  </environment>
</eeml>
});
ok($pachube->get, 'get success');
