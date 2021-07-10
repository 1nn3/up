#!/usr/bin/env perl

use diagnostics;
use strict;
use utf8;
use warnings;

use ExtUtils::MakeMaker;
use File::ShareDir::Install;

install_share dist => 'dist';

WriteMakefile(
    NAME         => 'App::Up',
    VERSION_FROM => 'lib/App/Up.pm',
    AUTHOR       => q{nobody <nobody>},

    #NO_MYMETA => 1,
    MAN1PODS => {
        'bin/list-addresses.pl'        => '$(INST_MAN1DIR)/list-addresses.1p',
        'bin/list-remote-addresses.pl' => '$(INST_MAN1DIR)/list-remote-addresses.1p',
        'bin/scan-addresses.pl'        => '$(INST_MAN1DIR)/scan-addresses.1p',
        'bin/scan-remote-addresses.pl' => '$(INST_MAN1DIR)/scan-remote-addresses.1p',
    },
    MAN3PODS => {
        'lib/App/Up.pm' => '$(INST_MAN3DIR)/App::Up.p3',
    },
    PM => {
        'bin/list-addresses.pl'        => '$(INST_BIN)/list-addresses',
        'bin/list-remote-addresses.pl' => '$(INST_BIN)/list-remote-addresses',
        'bin/scan-addresses.pl'        => '$(INST_BIN)/scan-addresses',
        'bin/scan-remote-addresses.pl' => '$(INST_BIN)/scan-remote-addresses',
        'bin/up-cronjob.sh'            => '$(INST_BIN)/up-cronjob',
        'lib/App/Up.pm'                => '$(INST_LIBDIR)/Up.pm',
    },
    PREREQ_PM => {
        'Config::General'       => undef,
        'Data::Dumper'          => undef,
        'Fcntl'                 => undef,
        'File::Basename'        => undef,
        'File::HomeDir'         => undef,
        'File::Path'            => undef,
        'File::ShareDir'        => undef,
        'File::Spec'            => undef,
        'File::Temp'            => undef,
        'Geo::IP'               => undef,
        'Getopt::Long'          => undef,
        'IO::Interface::Simple' => undef,
        'List::Util'            => undef,
        'Net::DNS'              => undef,
        'Net::Netmask'          => undef,
        'Net::Traceroute'       => undef,
        'Parse::Netstat'        => undef,
        'Text::Trim'            => undef,
        'Tie::File'             => undef,
    }
);

package MY;
use File::ShareDir::Install qw(postamble);

