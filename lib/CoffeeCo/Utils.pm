package CoffeeCo::Utils;
use strict;
use warnings;
use Path::Tiny;
#use Data::UUID;
#use UUID::Tiny qw<create_uuid_as_string>;
use CoffeeCo::DB;
use JSON::MaybeXS qw< encode_json decode_json >;

use constant {
    'DB_PATH' => path('db'),
};

sub create_db {
    # set up
    my $path = shift || DB_PATH();
    $path->is_dir
        or $path->mkpath();

    return CoffeeCo::DB->new( 'path' => $path );
}

1;

__END__

=pod

=head1 SYNOPSIS

    my $db = CoffeeCo::Utils::create_db();

=head1 FUNCTIONS

=head2 create_db

    create_db();

Create a new database object.
