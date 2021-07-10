#!/usr/bin/env perl

use diagnostics;
use strict;
use utf8;
use warnings;

use Data::Dumper;
use Fcntl;
use File::Temp (":POSIX");
use Getopt::Long;
use Tie::File;

use App::Up;

# Kommandozeilenargumente einlesen
GetOptions(
    "nmap-args=s" => \$App::Up::config{scan_remote_addresses_nmap_args},
    "nmap-cmd=s"  => \$App::Up::config{nmap_cmd},
    "quiet"       => \$App::Up::config{quiet},
    "verbose"     => \$App::Up::config{verbose},
) || die("Error in command-line-arguments: $!");

# Standardwerte setzen
$App::Up::config{ip_version}      //= undef;
$App::Up::config{nmap_cmd}        //= "nmap";
$App::Up::config{quiet}           //= 0;
$App::Up::config{scan_remote_addresses_nmap_args} //= "-Pn -A --script=vuln";
$App::Up::config{temp_path}       //= "/dev/shm";
$App::Up::config{verbose}         //= 0;

my $temp_file = File::Temp::tempnam( $App::Up::config{temp_path}, undef );
my @targets;
tie @targets, 'Tie::File', $temp_file, mode => Fcntl::O_RDWR | Fcntl::O_CREAT;
push @targets, App::Up::remote_addresses;

# Scannen ...
my $command =
"${App::Up::config{nmap_cmd}} ${App::Up::config{rscan_nmap_args}} -iL $temp_file";
warn "$command\n";
system("$command") or warn "Couldn't exec Nmap/Zenmap command: $!";

END {
    unlink $temp_file or warn "Could not unlink $temp_file: $!";
}

=pod

=encoding utf8

=head1 NAME

scan-remote-addresses - scans all remote addresses

=head1 SYNOPSIS

B<scan-remote-addresses>

=head1 DESCRIPTION

Ein Wrapper für den Nmap/Zenmap Netzwerkscanner, welcher automatisch alle
verbundenen entfernten Hosts scannt.

=head1 DATEIEN

=over

=item XDG_USER_CONFIG_DIR/Perl/Up/config.ini

	scan_remote_addresses_nmap_args = -Pn -A --script=vuln
	nmap_cmd = zenmap --nmap nmap

=back

=head1 SIEHE AUCH

L<list-remote-addresses(1p)>

=cut

