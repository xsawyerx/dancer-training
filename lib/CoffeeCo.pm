package CoffeeCo;
use Dancer2 0.163000;
use CoffeeCo::Order;
use CoffeeCo::Utils;
use MIME::Base64;
use Crypt::Eksblowfish::Bcrypt qw<bcrypt_hash>;
use Time::HiRes qw<gettimeofday tv_interval>;

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

hook 'before' => sub { var 'start_time' => [ gettimeofday() ]; };

hook 'after' => sub {
    my $elapsed = tv_interval ( vars->{'start_time'}, [gettimeofday]);
    debug "Time for request: $elapsed";
};

hook 'before_template' => sub {
    my $vars = shift;
    $vars->{'admin'}  = session('username');
    $vars->{'now'}    = localtime;
    $vars->{'name'} ||= 'Stranger';
};

get '/' => sub { forward '/orders'; };

get '/orders' => sub {
    my @orders = $db->all_orders();

    template 'orders' => {
        orders => \@orders,
        admin  => session('username'),
    };
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

        $db->store_order($order);

        redirect '/';
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
        my $order = $db->order_by_id( route_parameters->get('id') )
            or send_error("Requested order not found", 404);
        $order->set_served();
        $db->update_order($order);
        return 1;
    };

    del '' => sub {
        my $order = $db->order_by_id( route_parameters->get('id') )
            or send_error("Requested order not found", 404 );
        $db->delete_order($order);
        return 1;
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
