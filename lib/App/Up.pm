use diagnostics;
use strict;
use utf8;
use warnings;

use Config::General;
use Data::Dumper;
use File::Basename;
use File::HomeDir;
use File::Path;
use File::ShareDir;
use File::Spec;
use Geo::IP;
use IO::Interface::Simple;
use List::Util;
use Net::DNS;
use Net::Netmask;
use Parse::Netstat;
use Text::Trim;

package App::Up {

    our $NAME    = "App-Up";
    our $VERSION = "0.01";

    # ~/.config/Perl
    our $CONFIG_DIR = File::HomeDir->my_dist_config( $NAME, { create => 1 } );

    # ~/.local/share/Perl
    our $DIST_DIR = File::HomeDir->my_dist_data( $NAME, { create => 1 } );

    # File::ShareDir::dist_dir works only if directory is installed
    # /usr/share/perl
    our $DISTDIR = File::ShareDir::dist_dir($NAME);

    sub get_file {
        my ($rel_file) = @_;
        my @dirs = ( $CONFIG_DIR, $DIST_DIR, $DISTDIR );

        for (@dirs) {
            File::Path::make_path($_);
            my $abs_file = File::Spec->catfile( $_, $rel_file );
            return $abs_file if ( -r $abs_file );
        }

        my $abs_file = File::Spec->catfile( get_file("."), $rel_file );
        File::Path::make_path( File::Basename::dirname($abs_file) );

        # Das Verz. exsitiert nun und somit kann $rel_file ggf. angelegt werden
        return ($abs_file);
    }

    my $config_file = get_file("config.ini");

    our %config = ();
    if ( -e $config_file ) {
        %config = Config::General::ParseConfig( -ConfigFile => $config_file );
    }

    sub addresses {
        my @network_blocks;
        for ( IO::Interface::Simple->interfaces ) {
            next if ( !$_->address );
            next if ( !$_->is_running );
            next if ( $_->is_loopback );
            push @network_blocks, Net::Netmask->new( $_->address, $_->netmask );
        }
        return List::Util::uniq sort @network_blocks;
    }

    sub remote_addresses {
        my $res = Parse::Netstat::parse_netstat(
            output => join( "", `netstat -4ntu` ) );
        return List::Util::uniq sort map { $_->{foreign_host} }
          @{ $res->[2]{'active_conns'} };
    }

    sub dns_reverse_look_up {
        my ($ip) = @_;
        my $res = Net::DNS::Resolver->new;
        my @dns_names;
        my $reply = $res->query( $ip, "PTR" );
        if ($reply) {
            foreach my $rr ( $reply->answer ) {
                push @dns_names, $rr->rdatastr;
            }
        }
        else {
            @dns_names = ( $res->errorstring );
        }
        return join " ", List::Util::uniq sort @dns_names;
    }

    sub geoip_look_up {
        my ($ip) = @_;

        my $gi = Geo::IP->open( '/usr/share/GeoIP/GeoIPCity.dat',
            Geo::IP::GEOIP_STANDARD | Geo::IP::GEOIP_MEMORY_CACHE );

        my $record = $gi->record_by_addr($ip);
        if ($record) {

            my $post_address = sprintf( "%s %s %s",
                $record->postal_code || "",
                $record->city        || "",
                $record->region_name || "",
            );

            Text::Trim::trim $post_address;

            return sprintf(
                "%s, %s\t%s\t%s %s",
                $record->country_code || "",
                $record->country_name || "",
                $post_address,
                $record->latitude  || "",
                $record->longitude || "",
            );
        }
        else {
            return "N/A";
        }
    }

    1;
}

