package rig::cmd::cpan;
use strict;
use CPAN;
use CPAN::Shell;
use rig '-load';

sub run {
    my $self = shift;
    my $parser = $rig::opts{parser};
    my $data = $parser->rc_parse;
    #return unless ref $data eq 'HASH';
    for my $task ( keys %$data ) {
        print "Loaded $task...\n";
        for my $module ( @{ $data->{$task} } ) {
            ref $module eq 'HASH' and $module = (keys %$module)[0];
            print "Installing $module...\n";
            $self->install_module($module);
        }
    }
}

sub install_module {
    my $self = shift;
    my $module = shift;
    CPAN::Shell->install( $module );
}

1;
