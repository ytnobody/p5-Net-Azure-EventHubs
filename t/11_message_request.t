use strict;
use warnings;
use Test::More;
use Test::Time time => 1476061810; # => 2016-10-10 10:10:10
use Net::Azure::EventHubs;

my $hub = Net::Azure::EventHubs->new(
    connection_string => 'Endpoint=sb://mysvc.servicebus.windows.net/;SharedAccessKeyName=mykey;SharedAccessKey=AexamplekeyAEXAMPLEKEYAexamplekeyAEXAMPLEKEY=;EntityPath=myentity',
);
isa_ok $hub, 'Net::Azure::EventHubs';

subtest 'simple messaging' => sub {
    my $req = $hub->message({Location => 'Oi-machi', Price => 1000, Result => 'Drunkenness'});
    isa_ok $req, 'HTTP::Request';
    isa_ok $req, 'Net::Azure::EventHubs::Request';
    can_ok $req, qw/do/;
    is $req->header('Content-Type'), 'application/atom+xml;type=entry;charset=utf-8';
    is $req->header('Authorization'), 'SharedAccessSignature sr=https%3a%2f%2fmysvc.servicebus.windows.net%2fmyentity%2fmessages&sig=nQDGh0YxA8O3SFO7SyrmnTK6BnP%2F33KShAbTXFjmYV0%3D&se=1476065410&skn=mykey';
    is $req->uri->scheme, 'https';
    is $req->uri->host, 'mysvc.servicebus.windows.net';
    is $req->uri->path, '/myentity/messages';
    is_deeply {$req->uri->query_form}, {timeout => 60, api_version => '2014-01'};
};

done_testing;