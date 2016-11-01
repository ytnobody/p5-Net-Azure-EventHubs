[![Build Status](https://travis-ci.org/ytnobody/p5-Net-Azure-EventHubs.svg?branch=master)](https://travis-ci.org/ytnobody/p5-Net-Azure-EventHubs)
# NAME

Net::Azure::EventHubs - A Client Class for Azure Event Hubs 

# SYNOPSIS

    use Net::Azure::EventHubs;
    my $eh = Net::Azure::EventHubs->new(
        connection_string => 'Endpoint=sb://...',
    );
    ## or use Net::Azure::Authorization::SAS for Authorization
    my $sas = Net::Azure::Authorization::SAS->new(connection_string => 'Endpoint=sb://...');
    $eh = Net::Azure::EventHubs->new(authorizer => $sas);
    $eh->message({Location => 'Roppongi', Temperature => 20});

# DESCRIPTION

Net::Azure::EventHubs is a cliant class for Azure Event Hubs.

If you want to know more information about Azure Event Hubs, please see [https://msdn.microsoft.com/en-us/library/azure/mt652157.aspx](https://msdn.microsoft.com/en-us/library/azure/mt652157.aspx). 

# METHODS

## new

    my $eh = Net::Azure::EventHubs->new(
        connection_string => 'Endpoint=sb://...',
    );

A constructor method. 

It requires the 'connection\_string' parameter that is a value of 'CONNECTION STRING–PRIMARY KEY' or 'CONNECTION STRING–SECONDARY KEY' on the 'Shared access policies' blade of Event Hubs in Microsoft Azure Portal. 

## message 

    $eh->message($payload);

Send a message that contains specified payload to Azure Event Hubs.

$payload is a hashref.  

# LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

ytnobody <ytnobody@gmail.com>
