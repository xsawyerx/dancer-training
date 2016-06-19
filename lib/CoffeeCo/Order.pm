package CoffeeCo::Order;
use Moo;
use MooX::Types::MooseLike::Base qw<Bool Str>;

has id => (
    is       => 'ro',
    isa      => Str,
    init_arg => undef,
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
    predicate => 'has_milk',
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
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    default => sub { localtime time },
);

sub set_served {
    my $self = shift;
    $self->_set_served(1);
    $self->served_time;
}

1;
