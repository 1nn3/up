#!/usr/bin/env perl

use diagnostics;
use strict;
use utf8;
use warnings;

use Getopt::Long;

use App::Up;

# Kommandozeilenargumente einlesen
GetOptions(
    "nmap-args=s" => \$App::Up::config{list_addresses_nmap_args},
    "nmap-cmd=s"  => \$App::Up::config{nmap_cmd},
    "quiet"       => \$App::Up::config{quiet},
    "targets=s"   => \$App::Up::config{targets},
    "verbose"     => \$App::Up::config{verbose},
) || die("Error in command-line-arguments: $!");

# Standardwerte setzen
$App::Up::config{list_addresses_nmap_args} //= "-A";
$App::Up::config{nmap_cmd}     //= "nmap";
$App::Up::config{quiet}        //= 0;
$App::Up::config{targets}      //= "./targets";
$App::Up::config{verbose}      //= 0;

if ( $App::Up::config{list_addresses_nmap_args} !~ m/-iL/ ) {
    if ( -e $App::Up::config{targets} ) {

        # Das Argument -iL <path/to/file> anfügen
        $App::Up::config{list_addresses_nmap_args} =
          "${App::Up::config{list_addresses_nmap_args}} -iL ${App::Up::config{targets}}";
    }
    else {
        $App::Up::config{list_addresses_nmap_args} =
          sprintf "${App::Up::config{list_addresses_nmap_args}} %s",
          join( " ", App::Up::addresses );
    }
}

# Scannen ...
my $command = "${App::Up::config{nmap_cmd}} ${App::Up::config{list_addresses_nmap_args}}";
warn "$command\n";
exec("$command") or warn "Couldn't exec Nmap/Zenmap command: $!";

=pod

=encoding utf8

=head1 NAME

scan-addresses - Scannt alle verbundenen Netzwerke

=head1 SYNOPSIS

B<scan-addresses>

Ping scan

	scan-addresses --nmap-args "-sP"

Deaktivierter Ping scan:

	scan-addresses --nmap-args "-Pn -A"

=head1 DESCRIPTION

Ein Wrapper für den Nmap/Zenmap Netzwerkscanner, welcher automatisch alle
verbundenen Netzwerke scannt.

=head1 OPTIONS

=over

=item --nmap-cmd <string>

Kommando das vom Wrapper ausgeführt wird.

Standardwert ist: nmap

Soll statt B<nmap(1)> das grafische Nmap Frontend B<zenmap(1)> genutzt
werden, setzen Sie `zenmap --nmap nmap' als Wert.

=item --nmap-args <string>

Dieser Wert wird direkt an den obigen Wert von B<--nmap-cmd> angehängt.

Standardwert ist: -A

Hinweis: Fehlt das Argument I<-iL>, wird die Ausgabe von B<lsip(1p)>,
oder, wenn die Datei `./targets' im Arbeitsverzeichnis gefunden wird `-iL
./targets' angefügt. Wobei der Wert `./targets' mittels I<--targets>
geändert werden kann.

=item --targets <path/to/file>

=back

=head1 DATEIEN

=over

=item XDG_USER_CONFIG_DIR/Perl/Up/config.ini

	up_nmap_args = -A
	nmap_cmd  = zenmap --nmap nmap
	targets   = ./targets

=back

=head1 SIEHE AUCH

L<list-addresses(1p)>

L<zenmap(1)>, L<nmap(1)>

=cut
