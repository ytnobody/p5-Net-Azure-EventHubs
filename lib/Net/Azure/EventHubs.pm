package Net::Azure::EventHubs;
use 5.008001;
use strict;
use warnings;

use Net::Azure::EventHubs::Request;
use Carp;
use JSON;
use LWP::UserAgent;
use Digest::SHA 'hmac_sha256';
use MIME::Base64 'encode_base64';
use URI::Escape 'uri_escape';
use URI;
use String::CamelCase 'decamelize';

use Class::Accessor::Lite (
    new => 0,
    ro  => [qw[
        connection_string 
        endpoint shared_access_key_name shared_access_key entity_path
        agent serializer expire timeout api_version
    ]],
);

our $VERSION              = "0.01";
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
    %param = (%param, $class->_parse_connection_string($param{connection_string})); 
    bless {%param}, $class;
}

sub _parse_connection_string {
    my ($class, $string) = @_;
    my %parsed = (map {split '=', $_, 2} split(';', $string));
    ( map {(decamelize($_) => $parsed{$_})} keys %parsed ); 
}

sub _expire_time {
    my ($self, $expire) = @_;
    $expire ||= $self->expire; 
    time + $expire;
}

sub _generate_sas_token {
    my ($self, $uri) = @_;
    my $target_uri  = lc(uri_escape(lc(sprintf("%s://%s%s", $uri->scheme, $uri->host, $uri->path))));
    my $expire_time = $self->_expire_time;
    my $to_sign     = "$target_uri\n$expire_time";
    my $signature   = encode_base64(hmac_sha256($to_sign, $self->shared_access_key));
    chomp $signature;
    sprintf 'SharedAccessSignature sr=%s&sig=%s&se=%s&skn=%s', $target_uri, uri_escape($signature), $expire_time, $self->shared_access_key_name;
}

sub _uri {
    my ($self, $path, %params) = @_;
    $path ||= '/';
    my $uri = URI->new($self->endpoint);
    $uri->scheme('https');
    $uri->path($path);
    $uri->query_form(%params);
    $uri;
}

sub _req {
    my ($self, $path, $payload, %params) = @_;
    $params{timeout}     ||= $self->timeout;
    $params{api_version} ||= $self->api_version;
    my $uri    = $self->_uri($path, %params);
    my $expire = $self->_expire_time;
    my $auth   = $self->_generate_sas_token($uri);
    my $data   = $self->serializer->encode($payload);
    my $req = Net::Azure::EventHubs::Request->new(
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
    my $path = sprintf "/%s/messages", $self->entity_path;
    my $req = $self->_req($path => $payload);
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

