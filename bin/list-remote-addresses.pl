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
    "details" => \$App::Up::config{details},
    "quiet"   => \$App::Up::config{quiet},
    "verbose" => \$App::Up::config{verbose},
) || die("Error in command-line-arguments: $!");

# Standardwerte setzen
$App::Up::config{details} //= 0;
$App::Up::config{quiet}   //= 0;
$App::Up::config{verbose} //= 0;

my $counter = 0;
my $line;

for (App::Up::remote_addresses) {

    if ( $App::Up::config{details} ) {
        my $geoip       = App::Up::geoip_look_up($_);
        my $dns_reverse = App::Up::dns_reverse_look_up($_);
        $line = "$_\t$geoip\t$dns_reverse";
    }
    else {
        $line = $_;
    }

    say $line;
    $counter++;
}

say $line;
$counter++;

exit !$counter;

=pod

=encoding utf8

=head1 NAME

list-remote-addresses - Zeigt von aktiven Verbindungen die entfernte Adresse

=head1 SYNOPSIS

B<list-remote-addresses> [--details]

Entfernte Adressen auflisten.

=head1 OPTIONS

=over

=item --details

With I<--details> country (geoip) and DNS reverse look up will done.

=back

=head1 SIEHE AUCH

L<scan-remote-addresses(1p)>

=cut


