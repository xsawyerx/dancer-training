package CoffeeCo::Utils;
use strict;
use warnings;
use KiokuDB;
use KiokuDB::Backend::Files;

sub create_db {
    # set up
    -d 'db' or mkdir 'db';
    my $db = KiokuDB->new(
        backend => KiokuDB::Backend::Files->new(
            dir        => 'db',
            serializer => 'yaml',
        )
    );
    return $db;
}


sub all_orders {
    my $db = shift
        or die "Must provide db object\n";

    my $orders = $db->all_objects;
    my @orders;

    while ( my $block = $orders->next ) {
        push @orders => @$block;
    }

    return @orders;
}

sub order_by_id {
    my $db = shift
        or die "Must provide db object\n";

    my $id = shift
        or die "Must provide id\n";

    return $db->lookup($id);
}

sub store_order {
    my $db = shift
        or die "Must provide db object\n";

    my $order = shift
        or die "Must provide order object\n";

    my $uuid = $db->store($order);
    $order->set_id($uuid);
    $db->update($order);
}

1;
