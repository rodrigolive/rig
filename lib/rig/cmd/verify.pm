package rig::cmd::verify;
use strict qw/vars/;

sub run {
    require rig;
    my $engine_import = rig->_setup_engine;
    rig->_setup_parser;
    &$engine_import();
}

1;
