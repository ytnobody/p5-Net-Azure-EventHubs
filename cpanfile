requires 'perl', '5.008001';
requires 'Class::Accessor::Lite';
requires 'HTTP::Request';
requires 'Digest::SHA';
requires 'LWP::UserAgent';
requires 'HTTP::Message';
requires 'URI';
requires 'JSON';
requires 'Carp';
requires 'String::CamelCase';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

