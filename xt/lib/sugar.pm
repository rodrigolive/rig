package sugar;
use strict;
use Carp;
use YAML::XS;
use Hook::LexWrap;
use version;

our %sugar_files;

sub import {
    my ($class, @args) = @_;
    my ($list_sugar, $list_pragma, $list_tasks) = discern_sugar(@args);    
    run_pragmas( @$list_pragma );
    my $pkg = caller;
    print "$pkg\n";
    my $import = build_import( @$list_sugar );
    #die Dump $import;
    my @list = map { @{ $import->{$_} } } @args;
    my ($first_module, $last);
    for my $module ( @list ) {
        no strict 'refs';
        my $name = $module->{name};
        my $version = $module->{version};
        my @module_args = ref $module->{args} eq 'ARRAY' ? @{$module->{args}} : ();

        print "  require $name\n";
        eval "require $name" or croak "sugar: $name: $@";
        check_versions( $name, $version );

        my $can_import = defined &{$name.'::import'};

        unless( $can_import ) {
            my $module_args_str = "'".join(q{','}, @module_args)."'"
                if @module_args > 0;
            print "   use $name $module_args_str\n";
            eval "package $pkg; use $name $module_args_str;"; # for things like Carp
        } else {
            $first_module ||= $module;
            my $import_sub = $name . "::import";
            if( $last ) {
                unless( *{$last} ) {
                    print "no code for $last\n";
                } else {
                    my $restore = $last;
                    # save original
                    my $original = *$restore{CODE};;
                    # wrap the import
                    print "    wrap $last\n";
                    wrap $restore,
                        post=>sub {
                            print " - post run $import_sub, restore $restore\n";
                            *{$restore}=$original if $restore;
                            @_=($name, @module_args);
                            goto &$import_sub };
                }
            }
            $last = $import_sub;
        }
    }
    $last = undef;
    if( $first_module ) {
        # start the chain, if any
        my @module_args = ref $first_module->{args} eq 'ARRAY' ? @{$first_module->{args}} : ();
        my $first_import = $first_module->{name}."::import";
        my $can_import = defined &{$first_import};
        return unless $can_import;
        print "    import $first_import\n";
        @_=($first_module->{name}, @module_args);
        goto &$first_import;
    }
}

sub check_versions {
    my ($name, $version) = @_;
    no strict q/refs/;
    my $current = ${$name.'::VERSION'}; 
    print "----------checking $current x $version.-----------\n";
    return unless defined $current && defined $version;
    croak "sugar: required module $name $version, but found $current"
        if version->parse($current) < version->parse($version); 
}

sub build_import {
    my @list  = @_;
    my $profile = rc_parse();
    my $ret = {};
    for( @list ) {
        my $items = $profile->{$_};
        croak "Content format for '$_' not supported"
            unless ref $items eq 'ARRAY';
        $ret->{$_} = [
            map {
                if( ref eq 'HASH' ) {
                    my %hash = %$_;
                    my $module = [keys %hash]->[0]; # ignore the rest
                    my @a = split / /, $module;
                    +{
                        name => $a[0],
                        version => $a[1],
                        args => $hash{$module},
                    }
                } else {
                    my @a = split / /;
                    +{
                        name => $a[0],
                        version => $a[1],
                    }
                }
            } @$items
        ];
    }
    return $ret;
}

sub discern_sugar {
    my (@sugar, @tasks, @pragmas);
    for( @_ ) {
        push( @tasks,$1 ),next if /^\:\:(.*)$/;
        push( @pragmas,$1 ),next if /^\:(.*)$/;
        push( @sugar,$_ );
    }
    return \@sugar, \@pragmas, \@tasks;
}

sub run_pragmas {
        
}

sub use_them {
    my $pkg = shift;
    my %uses = @_;
}

sub rc_parse {
    my $file = $ENV{PERL_SUGAR} || '.sugar';
    $sugar_files{$file} && return $sugar_files{$file};
    croak 'No .sugar found' unless -e $file;
    return $sugar_files{$file} = parse_file( $file );
}

sub parse_file {
    my $file = shift;
    open my $ff, '<', $file;
    my $yaml = YAML::XS::Load( join '',<$ff> ) or croak $@;
    close $ff;
    return $yaml;
}

sub unimport {
    my ($class, @args) = @_;
    my $pkg = caller;
    print "$pkg\n";
    my $import = build_import( @args );
    #die Dump $import;
    my @list = map { @{ $import->{$_} } } @args;
    my ($first_module, $last);
    for my $module ( reverse @list ) {
        no strict 'refs';
        my $name = $module->{name};
        my @module_args = ref $module->{args} eq 'ARRAY' ? @{$module->{args}} : ();

        my $can_import = defined &{$name.'::unimport'};
        unless( $can_import ) {
            my $module_args_str = "'".join(q{','}, @module_args)."'"
                if @module_args > 0;
            eval "package $pkg; no $name $module_args_str;"; # for things like Carp
        } else {
            $first_module ||= $module;
            my $import_sub = $name . "::import";
            if( $last ) {
                unless( *{$last} ) {
                    print "no code for $last\n";
                } else {
                    my $restore = $last;
                    # save original
                    my $original = *$restore{CODE};;
                    # wrap the import
                    print "    wrap $last\n";
                    wrap $restore,
                        post=>sub {
                            print " - post run $import_sub, restore $restore\n";
                            *{$restore}=$original if $restore;
                            @_=($name, @module_args);
                            goto &$import_sub };
                }
            }
            $last = $import_sub;
        }
    }
    $last = undef;
    if( $first_module ) {
        # start the chain, if any
        my @module_args = ref $first_module->{args} eq 'ARRAY' ? @{$first_module->{args}} : ();
        my $first_import = $first_module->{name}."::unimport";
        my $can_import = defined &{$first_import};
        return unless $can_import;
        @_=($first_module->{name}, @module_args);
        goto &$first_import;
    }
}
1;
