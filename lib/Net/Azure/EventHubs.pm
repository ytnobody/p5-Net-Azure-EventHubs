package Net::Azure::EventHubs;
use 5.008001;
use strict;
use warnings;

use Net::Azure::EventHubs::Request;
use Net::Azure::Authorization::SAS;
use JSON;
use LWP::UserAgent;
use URI;

use Class::Accessor::Lite (
    new => 0,
    ro  => [qw[
        agent 
        timeout 
        serializer 
        api_version 
        authorizer
    ]],
);

our $VERSION              = "0.01";
our $DEFAULT_API_VERSION  = '2014-01';
our $DEFAULT_TIMEOUT      = 60;

sub new {
    my ($class, %param)   = @_;
    $param{agent}         = LWP::UserAgent->new(agent => sprintf('%s/%s', $class, $VERSION));
    $param{serializer}    = JSON->new->utf8(1);
    $param{authorizer}  ||= Net::Azure::Authorization::SAS->new(connection_string => $param{connection_string});
    $param{api_version} ||= $DEFAULT_API_VERSION;
    $param{timeout}     ||= $DEFAULT_TIMEOUT;
    bless {%param}, $class;
}

sub _uri {
    my ($self, $path, %params) = @_;
    $path ||= '/';
    my $uri = URI->new($self->authorizer->endpoint);
    $uri->scheme('https');
    $uri->path($path);
    $uri->query_form(%params);
    $uri;
}

sub _req {
    my ($self, $path, $payload, %params) = @_;
    $params{timeout}     ||= $self->timeout;
    $params{api_version} ||= $self->api_version;
    my $uri  = $self->_uri($path, %params);
    my $auth = $self->authorizer->token($uri->as_string);
    my $data = $self->serializer->encode($payload);
    my $req  = Net::Azure::EventHubs::Request->new(
        POST => $uri->as_string,
        [ 
            'Authorization' => $auth,
            'Content-Type'  => 'application/atom+xml;type=entry;charset=utf-8',
        ],
        $data,
    );
    $req->agent($self->agent);
    $req;
}

sub message {
    my ($self, $payload) = @_;
    my $path = sprintf "/%s/messages", $self->authorizer->{entity_path};
    my $req = $self->_req($path => $payload);
    $req;
}


1;
__END__

=encoding utf-8

=head1 NAME

Net::Azure::EventHubs - A Client Class for Azure Event Hubs 

=head1 SYNOPSIS

    use Net::Azure::EventHubs;
    my $eh = Net::Azure::EventHubs->new(
        connection_string => 'Endpoint=sb://...',
    );
    ## or use Net::Azure::Authorization::SAS for Authorization
    my $sas = Net::Azure::Authorization::SAS->new(connection_string => 'Endpoint=sb://...');
    $eh = Net::Azure::EventHubs->new(authorizer => $sas);
    $eh->message({Location => 'Roppongi', Temperature => 20});

=head1 DESCRIPTION

Net::Azure::EventHubs is a cliant class for Azure Event Hubs.

If you want to know more information about Azure Event Hubs, please see L<https://msdn.microsoft.com/en-us/library/azure/mt652157.aspx>. 

=head1 METHODS

=head2 new

    my $eh = Net::Azure::EventHubs->new(
        connection_string => 'Endpoint=sb://...',
    );

A constructor method. 

It requires the 'connection_string' parameter that is a value of 'CONNECTION STRING–PRIMARY KEY' or 'CONNECTION STRING–SECONDARY KEY' on the 'Shared access policies' blade of Event Hubs in Microsoft Azure Portal. 

=head2 message 

    $eh->message($payload);

Send a message that contains specified payload to Azure Event Hubs.

$payload is a hashref.  

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

