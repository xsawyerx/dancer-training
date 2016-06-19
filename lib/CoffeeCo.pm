package CoffeeCo;
use Dancer2 0.163000;
use CoffeeCo::Order;
use CoffeeCo::Utils;
use MIME::Base64;
use Crypt::Eksblowfish::Bcrypt qw<bcrypt_hash>;

my $db = CoffeeCo::Utils::create_db();

my $salt = config->{'passwd_salt'}
    or die "Missing passwd_salt in config\n";

length $salt == 16
    or die "passwd_salt must be 16 characters long\n";

my %users;
{
    my $passwd_file = config->{'passwd_file'}
        or die "Missing passwd_file in config\n";
    open my $fh, '<', $passwd_file
        or die "Cann't open $passwd_file: $!\n";

    while ( my $line = <$fh> ) {
        my ( $user, $pass ) = split ':', $line;
        $users{$user} = $pass;
    }

    close $fh
        or die "Cannot close $passwd_file: $!\n";
}

hook before => sub { var scope => $db->new_scope };

hook before_template => sub {
    my $vars = shift;
    $vars->{'admin'}  = session('username');
    $vars->{'name'} ||= 'Stranger';
};

get '/orders' => sub {
    my @orders = CoffeeCo::Utils::all_orders($db);

    template 'orders' => {
        orders => \@orders,
        admin  => query_parameters->get('admin'),
    };
};

get '/' => sub {
    redirect '/orders';
};

prefix '/new_order' => sub {
    get '' => sub {
        template new_order => {
            name => query_parameters->get('name') || 'Stranger',
            now  => scalar localtime,
        };
    };

    post '' => sub {
        my $params = body_parameters;
        my $order  = CoffeeCo::Order->new(
            name          => $params->get('name'),
            size          => $params->get('cup_size'),
            milk          => $params->get('milk'),
            whipped_cream => $params->get('whipped_cream'),
            syrup         => [ $params->get_all('syrup') ],
        );

        CoffeeCo::Utils::store_order( $db, $order );

        redirect '/orders';
    };
};

post '/login' => sub {
    my $username = body_parameters->get('username');
    my $password = body_parameters->get('password');
    if ( check_password( $username, $password ) ) {
        session username => $username;
        redirect '/';
    }

    redirect '/login?failure=1';
};

prefix '/order/:id' => sub {
    patch '' => sub {
        my $order = CoffeeCo::Utils::order_by_id( $db, route_parameters->get('id') )
            or send_error("Requested order not found", 404);
        $order->set_served();
        $db->update($order);
    };

    del '' => sub {
        my $order = CoffeeCo::Utils::order_by_id( $db, route_parameters->get('id') )
            or send_error("Requested order not found", 404 );
        $db->delete($order);
    };
};


sub check_password {
    my ( $username, $password ) = @_;
    my $user_pass = $users{$username};

    if ( ! $user_pass ) {
        warning("Unknown username: $username");
        return;
    }

    my $hash = bcrypt_hash({
        key_nul => 1,
        cost    => 8,
        salt    => $salt,
    }, $password );

    return encode_base64($hash) eq $user_pass;
}

1;
