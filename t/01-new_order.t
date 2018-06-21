use strict;
use warnings;
use Test::More;
use Test::WWW::Mechanize::PSGI;
use Plack::Test;
use HTTP::Request;
use t::lib::CoffeeCoTests;

my ( $mech, $app ) = t::lib::CoffeeCoTests::mech();

subtest 'New order loading' => sub {
    $mech->get_ok('/new_order');
};

subtest 'Links' => sub {
    $mech->page_links_ok('Check all links');
    my @links = $mech->followable_links();
    is_deeply(
        \@links,
        [],
        'Got all links',
    );
};

subtest 'Can submit new order' => sub {
    $mech->get_ok('/new_order');
    $mech->field( 'syrup', ['moca', 'vanilla'] );
    $mech->submit_form_ok(
        {
            form_number => 1,
            fields      => {
                name     => 'Test 1',
                cup_size => 'tiny',
                milk     => 'no',
            },
        },
        'Created first test order',
    );

    $mech->get_ok('/new_order');
    $mech->field( 'syrup', ['chocolate'] );
    $mech->submit_form_ok(
        {
            form_number => 1,
            fields      => {
                name     => 'Test 2',
                cup_size => 'humongous',
                milk     => 'coconut',
            },
        },
        'Created second test order',
    );

    $mech->get_ok('/new_order');
    $mech->field( 'syrup', 'chocolate' );
    $mech->submit_form_ok(
        {
            form_number => 1,
            fields      => {
                name     => 'Test 2',
                cup_size => 'normal',
                milk     => 'almond',
            },
        },
        'Created third test order',
    );
};

done_testing;
