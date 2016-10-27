package Net::Azure::EventHubs::Request;
use strict;
use warnings;

use parent 'HTTP::Request';
use Net::Azure::EventHubs::Response;
use Carp;

use Class::Accessor::Lite (
    new => 0,
    rw  => [qw[agent]],
);

sub do {
    my $self = shift;
    my $res = $self->agent->request($self);
    croak $res->status_line if !$res->is_success;
    bless $res, 'Net::Azure::EventHubs::Response';
}

1;