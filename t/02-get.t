#!/usr/bin/perl -w
use strict;
use Test::More tests => 6;
use IO::Socket::INET;

use_ok('Net::Pachube');

my $pachube = Net::Pachube->new(feed => 2);
ok($pachube, 'constructor');
is($pachube->feed, 2, 'feed initialized');
is($pachube->feed(1), 1, 'feed set');
is($pachube->feed, 1, 'feed retrieved');
is($pachube->feed_url, 'http://www.pachube.com/api/1.xml', 'feed url');
