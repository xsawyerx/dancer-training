use strict;
use warnings;
use Test::More;
use Test::WWW::Mechanize::PSGI;
use Plack::Test;
use HTTP::Request;
use t::lib::CoffeeCoTests;

my ( $mech, $app ) = t::lib::CoffeeCoTests::mech();

subtest 'Index basics' => sub {
    $mech->get_ok('/');
    $mech->page_links_ok('Check all links');
};

subtest 'Index redirects' => sub {
    my $test = Plack::Test->create($app);
    my $response = $test->request( HTTP::Request->new( GET => '/' ) );
    ok( $response->is_redirect, 'Index redirects' );
    like(
        $response->content,
        qr{This item has moved.*/orders},
        'Redirects to /orders',
    );
};

done_testing;
