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

__END__

=pod

=head1 FUNCTIONS

=head2 create_db

    create_db();

Called to create a new database object.

=head2 all_orders

    my @orders = all_orders($db);

Retrieve all the orders from a database. Returns C<CoffeeCo::Order>
objects.

=head2 order_by_id

    my $order = order_by_id( $db, $order_id );

Returns a C<CoffeeCo::Order> object from a database using an ID.

=head2 store_order

    store_order( $db, $order );

Stores in the database a C<CoffeeCo::Order> object.
