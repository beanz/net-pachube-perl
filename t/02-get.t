#!/usr/bin/perl -w
use strict;
use Test::More tests => 55;

use_ok('Net::Pachube');

delete $ENV{PACHUBE_API_KEY}; # ignore users key if any
my $pachube = Net::Pachube->new(feed => 2);
ok($pachube, 'constructor');
is($pachube->feed, 2, 'feed initialized');
is($pachube->feed(1), 1, 'feed set');
is($pachube->feed, 1, 'feed retrieved');
is($pachube->xml_url, 'http://www.pachube.com/api/1.xml', 'feed xml url');
is($pachube->csv_url, 'http://www.pachube.com/api/1.csv', 'feed csv url');
is($pachube->api_url, 'http://www.pachube.com/api.xml', 'api urlv');
is($pachube->pachube_url('http://localhost/api'), 'http://localhost/api',
   'pachube url');
eval { $pachube->get; };
like($@, qr/^No pachube api key defined\./, 'no key defined - get');
eval { $pachube->put; };
like($@, qr/^No pachube api key defined\./, 'no key defined - put');
eval { $pachube->post; };
like($@, qr/^No pachube api key defined\./, 'no key defined - post');
is($pachube->key('blahblahblah'), 'blahblahblah', 'key set');

my $response;
my $request;
{
  package MockUA;
  sub new {
    bless {}, 'MockUA';
  }
  sub default_header {
    $_[0]->{default_header} = $_[1];
  }
  sub request {
    $request = $_[1];
    $response;
  }
  1;
}
my $ua = MockUA->new;
is($pachube->user_agent($ua), $ua, 'set user_agent to mock object');
$response =  HTTP::Response->new( '401', 'Unauthorized');
my $resp = $pachube->get();
is($resp->http_response->status_line, '401 Unauthorized',
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
$resp = $pachube->get;
ok($resp->is_success, 'get success');
is($resp->title, 'Temperature', 'title');
is($resp->description, 'Temperature', 'description');
is($resp->id, '1', 'id');
is($resp->feed, 'http://www.pachube.com/api/1.xml', 'feed');
is($resp->creator, 'http://www.haque.co.uk', 'creator');
is($resp->status, 'live', 'status');
is($resp->data, 22.3, 'data value');
is(int $resp->data_min, 0, 'data min');
is(int $resp->data_max, 34, 'data max');
is($resp->data_tag, 'temperature', 'data tag');
is_deeply([sort keys %{$resp->location}],
          [qw/disposition domain exposure lat lon name/],
          'location structure');
is($resp->location('domain'), 'physical', 'location element');

$response =
  HTTP::Response->new('200', 'OK', undef,
                      q{<?xml version="1.0" encoding="UTF-8"?>
<eeml xmlns="http://www.eeml.org/xsd/005"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="http://www.eeml.org/xsd/005 http://www.eeml.org/xsd/005/005.xsd" version="5">
    <environment updated="2007-05-04T18:13:51.0Z" creator="http://www.haque.co.uk" id="1">
        <title>A Room Somewhere</title>
        <feed>http://www.pachube.com/feeds/1.xml</feed>
        <status>frozen</status>
        <description>This is a room somewhere</description>
        <icon>http://www.roomsomewhere/icon.png</icon>
        <website>http://www.roomsomewhere/</website>
        <email>myemail@roomsomewhere</email>
        <location exposure="indoor" domain="physical" disposition="fixed">
            <name>My Room</name>
            <lat>32.4</lat>
            <lon>22.7</lon>
            <ele>0.2</ele>
        </location>
        <data id="0">
            <tag>temperature</tag>
            <value minValue="23.0" maxValue="48.0">36.2</value>
            <unit symbol="C" type="derivedSI">Celsius</unit>
        </data>
        <data id="1">
            <tag>blush</tag>
            <tag>redness</tag>
            <tag>embarrassment</tag>
            <value minValue="0.0" maxValue="100.0">84.0</value>
            <unit type="contextDependentUnits">blushesPerHour</unit>
        </data>
        <data id="2">
            <tag>length</tag>
            <tag>distance</tag>
            <tag>extension</tag>
            <value minValue="0.0">12.3</value>
            <unit symbol="m" type="basicSI">meter</unit>
        </data>
    </environment>
</eeml>
});
$resp = $pachube->get;
is_deeply($resp->data_tag(2),[qw/length distance extension/], 'data tag 2');
is($resp->data(2), 12.3, 'data 2');
is($resp->data_min(2), '0.0', 'data min 2');
is($resp->data_max(2), undef, 'data max 2');

$response =
  HTTP::Response->new('200', 'OK', undef, q{ });
$resp = $pachube->put(9.2, 44);
ok($resp->is_success, 'put successful');
is($request->uri, 'http://localhost/api/1.csv', 'request->uri');
is($request->method, 'PUT', 'request->method');
is($request->content, '9.2,44', 'request->content');

$response =
  HTTP::Response->new('200', 'OK', undef, q{ });
$resp = $pachube->put(9.2, 44);
ok($resp->is_success, 'put successful');
is($request->uri, 'http://localhost/api/1.csv', 'request->uri');
is($request->method, 'PUT', 'request->method');
is($request->content, '9.2,44', 'request->content');

$response =
  HTTP::Response->new('201', 'OK',
                      [ Location => "http://www.pachube.com/api/2.xml" ],
                      q{ });
$resp = $pachube->post(title => "Outside Temperature");
is($request->content,
   q{<?xml version="1.0" encoding="UTF-8"?>
<eeml xmlns="http://www.eeml.org/xsd/005"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="http://www.eeml.org/xsd/005 http://www.eeml.org/xsd/005/005.xsd" version="5">
<environment>
  <title>Outside Temperature</title>
</environment>
</eeml>
}, 'post request->content - 1');
ok($resp->is_success, 'post successful');
is($resp->feed_location, 'http://www.pachube.com/api/2.xml',
   'post result - new feed location');
is($resp->feed_id, '2', 'post result - new feed id');

$response =
  HTTP::Response->new('500', 'OK', undef, q{ });
$resp = $pachube->post(title => "Outside Temperature");
ok(!$resp->is_success, 'post unsuccessful');
is($resp->feed_location, undef, 'post result - no new feed location');
is($resp->feed_id, undef, 'post result - no new feed id');

$response =
  HTTP::Response->new('422', 'OK',
                      [ Location => "http://www.pachube.com/api.xml" ],
                      q{ });
$resp = $pachube->post(title => "Outside Temperature");
ok(!$resp->is_success, 'post unsuccessful');
is($resp->feed_location, 'http://www.pachube.com/api.xml',
   'post result - not a feed location');
is($resp->feed_id, undef, 'post result - no feed id');

eval { $pachube->post; };
like($@, qr/^New feed should have a 'title' attribute\./,
     'no title - post');

$response =
  HTTP::Response->new('201', 'OK',
                      [ Location => "http://www.pachube.com/api/22.xml" ],
                      q{ });
$resp = $pachube->post(title => 'Outside Humidity',
                       description => 'Humidity outside',
                       website => 'http://www.example.com/',
                       icon => 'http://www.example.com/icon.png',
                       email => 'no-one@example.com',
                       exposure => 'outdoor',
                       disposition => 'fixed',
                       domain => 'mobile',
                       location_name => 'Middle of nowhere',
                       lat => 1,
                       lon => 2,
                       ele => 100,
                      );
is($request->content,
   q{<?xml version="1.0" encoding="UTF-8"?>
<eeml xmlns="http://www.eeml.org/xsd/005"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="http://www.eeml.org/xsd/005 http://www.eeml.org/xsd/005/005.xsd" version="5">
<environment>
  <description>Humidity outside</description>
  <email>no-one@example.com</email>
  <icon>http://www.example.com/icon.png</icon>
  <location disposition="fixed" domain="mobile" exposure="outdoor">
    <name>Middle of nowhere</name>
    <ele>100</ele>
    <lat>1</lat>
    <lon>2</lon>
  </location>
  <title>Outside Humidity</title>
  <website>http://www.example.com/</website>
</environment>
</eeml>
}, 'post request->content - 2');
ok($resp->is_success, 'post successful');
is($resp->feed_location, 'http://www.pachube.com/api/22.xml',
   'post result - new feed location');
is($resp->feed_id, '22', 'post result - new feed id');

