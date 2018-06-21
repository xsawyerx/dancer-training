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
    is_deeply(
        \@links,
        [],
        'Got all links',
    );
};

subtest 'Found all orders' => sub {
    my $first;
    wq( $mech->content )->find('table > tr')
        ->each(sub {
            $first++ or return;
            ::p $_->html;
        });
};

done_testing;
