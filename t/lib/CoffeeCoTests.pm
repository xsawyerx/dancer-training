package t::lib::CoffeeCoTests;
use strict;
use warnings;
use Test::More;
BEGIN { use_ok('CoffeeCo') };

sub mech {
    my $app = $ENV{'PLACK_PROXY'}
            ? Plack::App::Proxy->new( remote => $ENV{'PLACK_PROXY'} )->to_app
            : CoffeeCo->to_app;

    return (
        Test::WWW::Mechanize::PSGI->new( app => $app ),
        $app,
    );
}

1;
