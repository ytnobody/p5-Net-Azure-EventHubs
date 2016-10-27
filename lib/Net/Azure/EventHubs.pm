package Net::Azure::EventHubs;
use 5.008001;
use strict;
use warnings;

use Net::Azure::EventHubs::Request;
use Carp;
use JSON;
use LWP::UserAgent;
use Digest::SHA 'hmac_sha256_base64';
use URI::Escape 'uri_escape';
use URI;

use Class::Accessor::Lite (
    new => 0,
    ro  => [qw[agent serializer name sas_key_name sas_key_value expire timeout api_version]],
);

our $VERSION              = "0.01";
our $ENDPOINT_FORMAT      = '%s.servicebus.windows.net';
our $DEFAULT_TOKEN_EXPIRE = 3600;
our $DEFAULT_TIMEOUT      = 60;
our $DEFAULT_API_VERSION  = '2014-01';

sub new {
    my ($class, %param)   = @_;
    $param{agent}         = LWP::UserAgent->new(agent => sprintf('%s/%s', $class, $VERSION));
    $param{serializer}    = JSON->new->utf8(1);
    $param{expire}      ||= $DEFAULT_TOKEN_EXPIRE;
    $param{timeout}     ||= $DEFAULT_TIMEOUT;
    $param{api_version} ||= $DEFAULT_API_VERSION;
    bless {%param}, $class;
}

sub _expire_time {
    my ($self, $expire) = @_;
    $expire ||= $self->expire; 
    time + $expire;
}

sub _generate_sas_token {
    my ($self, $expire_time) = @_;
    my $target_uri = $self->_shared_resource_domain;
    my $signature  = hmac_sha256_base64("$target_uri\n$expire_time", $self->sas_key_value);
    sprintf 'SharedAccessSignature sr=%s&sig=%s&se=%s&skn=%s', 
        $target_uri, 
        uri_escape($signature), 
        $expire_time, 
        $self->sas_key_name
    ;
}

sub _shared_resource_domain {
    my $self = shift;
    sprintf $ENDPOINT_FORMAT, $self->name;
}

sub _uri {
    my ($self, $path, %params) = @_;
    $path ||= '/';
    my $uri = URI->new("https://". $self->_shared_resource_domain);
    $uri->path($path);
    $uri->query_form(%params);
    $uri;
}

sub _req {
    my ($self, $path, $payload, %params) = @_;
    $params{timeout}     ||= $self->timeout;
    $params{api_version} ||= $self->api_version;
    my $url    = $self->_uri($path, %params)->as_string;
    my $expire = $self->_expire_time;
    my $auth   = $self->_generate_sas_token($expire);
    my $data   = $self->serializer->encode($payload);
    my $req = Net::Azure::EventHubs::Request->new(
        POST => $url,
        [ 
            'Authorization' => $auth,
            'Content-Type'  => 'application/atom+xml;type=entry;charset=utf-8',
            'Host'          => $self->_shared_resource_domain,
        ],
        $data,
    );
    $req->agent($self->agent);
    $req;
}

sub message {
    my ($self, $entity, $payload) = @_;
    my $req = $self->_req("/$entity/messages" => $payload);
    $req;
}


1;
__END__

=encoding utf-8

=head1 NAME

Net::Azure::EventHubs - It's new $module

=head1 SYNOPSIS

    use Net::Azure::EventHubs;

=head1 DESCRIPTION

Net::Azure::EventHubs is ...

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

