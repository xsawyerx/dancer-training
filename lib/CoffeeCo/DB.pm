package CoffeeCo::DB;
use strict;
use warnings;
use Data::UUID;
use CoffeeCo::Order;
use JSON::MaybeXS qw< encode_json decode_json >;

sub new {
    my ( $class, %opts ) = @_;
    return bless {%opts}, $class;
}

sub all_orders {
    my $self = shift;

    my @orders = map +(
        CoffeeCo::Order->new( decode_json( $_->slurp_utf8 ) )
    ), $self->{'path'}->children;

    return @orders;
}

sub order_by_id {
    my $self = shift;
    my $id   = shift
        or die "Must provide id\n";

    return CoffeeCo::Order->new(
        decode_json( $self->{'path'}->child($id)->slurp_utf8 ),
    );
}

sub store_order {
    my $self  = shift;
    my $order = shift
        or die "Must provide order object\n";

    my $uuid = Data::UUID->new->create_str();

    $order->set_id($uuid);

    $self->{'path'}->child($uuid)->spew_utf8(
        encode_json( +{ %{$order} } ),
    );

    return 1;
}

sub update_order {
    my $self  = shift;
    my $order = shift
        or die "Must provide order object\n";

    $self->{'path'}->child( $order->id )->spew_utf8(
        encode_json( +{ %{$order} } ),
    );

    return 1;
}

sub delete_order {
    my $self  = shift;
    my $order = shift
        or die "Must provide order object\n";

    my $file = $self->{'path'}->child( $order->id );
    $file->exists
        and return $file->remove;

    return;
}

1;

__END__

=pod

=head1 SYNOPSIS

=head1 FUNCTIONS

=head2 all_orders

    my @orders = $db->all_orders();

Retrieve all the orders from a database. Returns C<CoffeeCo::Order>
objects.

=head2 order_by_id

    my $order = $db->order_by_id($order_id);

Returns a C<CoffeeCo::Order> object from a database using an ID.

=head2 store_order

    $db->store_order($order);

Stores in the database a C<CoffeeCo::Order> object.

=head2 update_order

    $db->update_order($order);

Updates an existing order.

=head2 delete_order

    $db->delete_order($order);

Deletes an existing order.
