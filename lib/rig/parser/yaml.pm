package rig::parser::yaml;
use strict;
use Carp;

our %rig_files;
our $CURR_RC_FILE;

sub parse {
    my $self = shift;
    my $path = $CURR_RC_FILE = shift || $self->_find_first_rig_file();
    $rig_files{$path} && return $rig_files{$path}; # cache?
    confess 'No .perlrig file found' unless $path;
    return $rig_files{$path} = $self->parse_file( $path );
}

sub file {
    return $CURR_RC_FILE;
}

sub parse_file {
    my $self = shift;
    my $file = shift;
    open my $ff, '<', $file or confess $!;
    my $yaml = YAML::XS::Load( join '',<$ff> ) or confess $@;
    close $ff;
    return $yaml;
}

sub _rigpath {
    my $class = shift;
    return split( /[\:|\;]/, $ENV{PERL_RIG_PATH})
        if defined $ENV{PERL_RIG_PATH};

    return( Cwd::getcwd, File::HomeDir->my_home ); #TODO add caller's home
}


sub _is_module_task {
    shift =~ /^\:/;  
}

sub _has_rigfile_tasks {
    my $self = shift;
    for( @_ ) {
        return 1 unless _is_module_task($_)
    }
}


sub _find_first_rig_file {
    my $self = shift;
    return $ENV{PERLRIG_FILE} if -e $ENV{PERLRIG_FILE};
    my $path;
    # search path
    my $current = Cwd::getcwd;
    my $home = File::HomeDir->my_home;
    for( $self->_rigpath() ) {
        my $path = File::Spec->catfile( $_, '.perlrig' ); 
        return $path if -e $path;
    }

    # not in path, or no path specified
}
1;
