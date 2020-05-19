#!/usr/bin/perl
#  Simple HTTP Proxy Program using HTTP::Daemon.
#  based on example by (c) 2007 by Takaki Makino  http://www.snowelm.com/~t/

#  this script acts as http proxy and replaces HTTP HEAD requests to filmdienst.de by HTTP GET requests
#  this is required because Kodi sends out HTTP HEAD requests for thumb pictures
#  but filmdienst.de returns such an image for a HTTP GET but not for a HTTP HEAD request
#  example: https://www.filmdienst.de/bild/filmdb/142050

use strict;

use HTTP::Daemon;
use LWP::UserAgent;

my $ua = LWP::UserAgent->new();
my $d = HTTP::Daemon->new( 
	LocalPort => 8080
) || die;
print "[Proxy URL:", $d->url, "]\n";

# Avoid dying from browser cancel
$SIG{PIPE} = 'IGNORE';

my $loglevel = 0;

# Dirty pre-fork implementation
#fork(); fork(); fork();  # 2^3 = 8 processes

while (my $c = $d->accept) {
        while (my $request = $c->get_request) {
		print $c->sockhost . ": " . $request->method . " " .$request->uri->as_string . "\n" if $loglevel > 0;
		my $uri = $request->uri;
		if ($uri =~ /http:\/\/www\.filmdienst\.de.*?/) {
			$uri =~ s/http/https/;
			$request->uri($uri);
			if ($request->method eq "HEAD") {
				$request->method("GET");
				print "replacing HEAD by GET for image request\n" if $loglevel > 1;
			}
		}

		#$request->push_header( Via => "1.1 ". $c->sockhost );
		my $response = $ua->simple_request( $request );

		$c->send_response( $response );

	}
	$c->close;
	undef($c);
}