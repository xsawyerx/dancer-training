package CoffeeCo::Order;
use Moo;
use MooX::Types::MooseLike::Base qw<Bool Str>;

has id => (
    is       => 'ro',
    isa      => Str,
    writer   => 'set_id',
);

has create_time => (
    is      => 'ro',
    isa     => Str,
    default => sub { localtime time },
);

has name => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has size => (
    is       => 'ro',
    isa      => sub {
        $_[0] =~ /^(tiny|normal|humongous)$/
            or die "Incorrect type: $_[0]";
    },
    required => 1,
);

has milk => (
    is  => 'ro',
    isa => sub {
        !$_[0] || $_[0] =~ /^(no|dairy|soy|almond|coconut)$/
            or die "Incorrect type: $_[0]";
    },
    default => sub {'no'},
);

has whipped_cream => (
    is      => 'ro',
    isa     => Bool,
    default => sub {0},
);

has syrup => (
    is        => 'ro',
    isa       => sub {
        $_[0]         or  return;
        @{$_[0]} == 0 and return;
        ref $_[0] eq 'ARRAY' or die "Incorrect type: $_[0]\n";
        grep /^(caramel|moca|hazelnut|chocolate|vanilla|rum)$/, @{$_[0]}
            or die "Incorrect type: $_[0]";
    },
    predicate => 'has_syrup',
);

has served => (
    is      => 'ro',
    isa     => Bool,
    default => sub { 0 },
    writer  => '_set_served',
);

has served_time => (
    is     => 'ro',
    isa    => Str,
    writer => '_set_served_time',
);

sub set_served {
    my $self = shift;
    $self->_set_served(1);
    $self->_set_served_time( scalar localtime time );
}

1;

__END__

=pod

=head1 SYNOPSIS

    # somewhere in your program:
    my $db    = CoffeeCo::Utils::create_db();


    # new order:
    my $order = CoffeeCo::Order->new(
        name          => 'Sawyer',
        size          => 'humongous',
        milk          => 'coconut',
        whipped_cream => 0, # default
        syrup         => [ 'caramel', 'hazelnut' ],
    );

    $db->store_order($order);


    # find an order
    my $order = CoffeeCo::Utils::order_by_id(
        $order_id
    );


    # do stuff with an order

    if ( ! $order->served ) {
        # set served
        $order->set_served; # yay!
        # update the database
        $db->update($order);
    }

    # delete an order
    $db->delete($order);

=head1 ATTRIBUTES

=head2 id

An ID representing the order. This is B<read-only> and gets created
automatically after you create a new order object.

=head2 create_time

The created time for the order. This is a B<read-only> and gets
created automatically after you create a new order object.

=head2 name

A name for the order. This is a B<read-only> and B<required> to provide
when creating an order.

=head2 size

A size for the order. This is B<read-only> and B<required> to provide
when creating an order.

Available values:

=over 4

=item * C<tiny>

=item * C<normal>

=item * C<humongous>

=back

=head2 milk

A milk type for the order. This is B<read-only> and B<optional> when
creating an order.

Available milk types:

=over 4

=item * C<no>

=item * C<dairy>

=item * C<soy>

=item * C<almond>

=item * C<coconut>

=back

Default: B<no>.

=head2 whipped_cream

A boolean whether to have whipped cream with the order. Default: B<0>.

=head2 syrup

An arrayref of syrups. This is B<optional>.

Available syrups:

=over 4

=item * C<caramel>

=item * C<moca>

=item * C<hazelnut>

=item * C<chocolate>

=item * C<vanilla>

=item * C<rum>

=back

=head2 served

A boolean representing whether an order was already served.

=head2 served_time

A string representing when an order was served.

=head1 METHODS

=head2 has_syrup

    if ( $order->has_syrup ) {
        # syrup was provided
    }

Return a boolean for whether there is any syrup for the order.

=head2 set_served

    $order->set_served;

Sets the boolean that the serving was done, which then also adjusts the
time the serving was done.
