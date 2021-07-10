#!/usr/bin/env perl

use diagnostics;
use strict;
use utf8;
use warnings;

use feature 'say';

use Getopt::Long;
use IO::Interface::Simple;
use Net::Netmask;

use App::Up;

binmode( STDIN,  ":encoding(UTF-8)" );
binmode( STDOUT, ":encoding(UTF-8)" );
binmode( STDERR, ":encoding(UTF-8)" );

# Kommandozeilenargumente einlesen
GetOptions(
    "down"     => \$App::Up::config{down},
    "loopback" => \$App::Up::config{loopback},
    "details"  => \$App::Up::config{details},
    "quiet"    => \$App::Up::config{quiet},
    "verbose"  => \$App::Up::config{verbose},
) || die("Error in command-line-arguments: $!");

# Standardwerte setzen
$App::Up::config{down}        //= 0;
$App::Up::config{loopback}    //= 0;
$App::Up::config{print_flags} //= 0;
$App::Up::config{quiet}       //= 0;
$App::Up::config{verbose}     //= 0;

my $counter = 0;
my $line;

for ( IO::Interface::Simple->interfaces ) {

    if ( !$_->address ) {
        warn $_, ': has no address';
        next;
    }

    next if ( !$_->is_running && !$App::Up::config{down} );
    next if ( $_->is_loopback && !$App::Up::config{loopback} );
    my $block = Net::Netmask->new( $_->address, $_->netmask );

    if ( $App::Up::config{details} ) {
        $line = sprintf(
            "%s/%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s",
            $_->address,
            $block->bits,
            $_,
            ( $_->is_running )     ? "running"     : "",
            ( $_->is_broadcast )   ? "broadcast"   : "",
            ( $_->is_pt2pt )       ? "pt2pt"       : "",
            ( $_->is_loopback )    ? "loopback"    : "",
            ( $_->is_promiscuous ) ? "promiscuous" : "",
            ( $_->is_multicast )   ? "multicast"   : "",
            ( $_->is_notrailers )  ? "notrailers"  : "",
            ( $_->is_noarp )       ? "noarp"       : ""
        );
    }
    else {
        $line = sprintf "%s/%s", $_->address, $block->bits;
    }

    say $line;
    $counter++;

}

exit !$counter;

=pod

=encoding utf8

=head1 NAME

list-addresses - Zeigt IPv4-Adressen und verbundene Netzwerke an

=head1 SYNOPSIS

B<list-addresses> [--details]

=head1 DESCRIPTION

Zeigt IPv4-Adressen und verbundene Netzwerke an, wobei Interfaces die als
loopback und/oder down markiert sind ausgelassen werden.

=head1 OPTIONS

=over

=item --loopback

Zeigt auch als loopback markierte Interfaces an.

=item --down

Zeigt auch als down markierte Interfaces an.

=item --details

Zeigt den Namen und Details/Flags zum jeweiligen Interface an.

Ausgegeben werden die Flags in der Reihenfolge:
1) network block,
2) interface,
3) running,
4) broadcast,
5) pt2pt (point-to-point),
6) loopback,
7) promiscuous,
8) multicast,
9) notrailers,
10) noarp

	list-addresses --details | cut -f 2,1

=back

=head1 SIEHE AUCH

L<scan-addresses(1p)>

L<IO::Interface::Simple(3pm)>, L<Net::Netmask(3pm)>

=cut

