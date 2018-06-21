use strict;
use warnings;
use Test::More;
use Test::WWW::Mechanize::PSGI;
use Plack::Test;
use HTTP::Request;
use t::lib::CoffeeCoTests;
use Web::Query;

my ( $mech, $app ) = t::lib::CoffeeCoTests::mech();

subtest 'Orders page' => sub {
    $mech->get_ok('/orders');
    $mech->page_links_ok('Check all links');
    my @links = $mech->followable_links();
    is( scalar @links, 2, 'Got two links' );
    is( $links[0]->url, '/new_order', 'First link leads to /new_order' );
    is( $links[1]->url, '/login',     'Second link leads to /login' );
};

subtest 'Found all orders' => sub {
    my ( $first, $num_orders );
    wq( $mech->content )->find('table > tr')->each(
        sub {
            $first++ or return;
            $num_orders++;
        },
    );


    is( $num_orders - 1, 3, 'Found three orders' );
};

done_testing;
