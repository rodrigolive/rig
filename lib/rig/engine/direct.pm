package rig::engine::direct;
use strict;
use Scope::Upper qw/localize unwind want_at :words/;

sub importx {
    my ($class, @args) = @_;
    #my ($list_rig, $list_pragma, $list_tasks) = discern_rig(@args);    
    #run_pragmas( @$list_pragma );
    my $pkg = caller;
    print "$pkg\n";
    my $import = build_import( @args );
    #die Dump $import;
    my @list = map { @{ $import->{$_} } } @args;
    my ($first_module, $last);
    for my $module ( @list ) {
        no strict 'refs';
        my $name = $module->{name};
        my $version = $module->{version};
        my @module_args = ref $module->{args} eq 'ARRAY' ? @{$module->{args}} : ();

        print "  require $name\n";
        eval "require $name" or croak "rig: $name: $@";
        check_versions( $name, $version );

        my $can_import = defined &{$name.'::import'};
#ssay();
        unless( $can_import ) {
            my $module_args_str = "'".join(q{','}, @module_args)."'"
                if @module_args > 0;
            print "   use $name $module_args_str\n";
            eval "package $pkg; use $name $module_args_str;"; # for things like Carp
        } else {
			print "--mod: $name, @module_args\n";
			#localize '$tt', \'nacana' => UP(2); 
			$name->import( @module_args );  # strict, warnings, etc
			#eval qq{
			#	package $pkg;
			#	\$name->import(\@module_args);
			#};
			#$name='feature';
			#print "--ret: " . $name->import(@module_args) . "\n";
        }
    }
}

1;

=head1 DESCRIPTION

An alternative implementation, without C<goto> and hooks.

=cut 
