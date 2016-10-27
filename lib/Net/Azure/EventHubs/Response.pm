package Net::Azure::EventHub::Response;
use strict;
use warnings;

use parent 'HTTP::Response';
use JSON;

sub as_hashref {
    my $self = shift;
    return if !$self->is_success;

    my $type = $self->header('Content-Type'); 
    if ($type && $type =~ /\Aapplication\/json/) {
        return JSON->new->utf8(1)->decode($self->content);
    }
}

1;