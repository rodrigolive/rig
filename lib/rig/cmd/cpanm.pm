package rig::cmd::cpanm;
use strict;
use base 'rig::cmd::cpan';

sub install_module {
    my $self = shift;
    my $module = shift;
    `cpanm "$module"`;
}

1;
