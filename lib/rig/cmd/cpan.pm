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
            $self->_install_module($module);
        }
    }
}

sub _install_module {
    my $self = shift;
    my $module = shift;
    CPAN::Shell->install( $module );
}

1;

=head1 NAME

rig::cmd::cpan - Command to install a rig with the cpan command line

=head1 SYNOPSYS

	rigup cpan

=head1 DESCRIPTION

This is quite experimental yet.

=head1 METHODS

=head2 run

Calls the CPAN shell to install rig modules. 

=cut 
