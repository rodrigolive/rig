package rig;
use strict;
use Carp;

our %opts = (
	engine => 'rig::engine::base',
	parser => 'rig::parser::yaml',
);

sub import {
    my $class        = shift;
	my @args = $class->_process_pragmas( @_ );
	return if !@args and ! exists $opts{'load'};

	# engine setup
    my $foo = $class->_setup_engine;
	
	# parser setup
    $class->_setup_parser;

	# go to the engine's import method
	return unless @args;
    my $instance     = $opts{engine}->new( %opts );
    @_ = ( $instance, @args );
    goto &$foo;
}

sub _process_pragmas {
    my $class        = shift;
	my @args;
    while( my $_ = shift ) {
		if( /^-(.+)$/ ) {
			# process pragma
			my $next = shift;
			unshift(@_, $next),$next=undef if $next =~ /^-/;
			$opts{ $1 } = $next // 1;
		} else {
			push @args, $_;
		}
	}
	return @args;
}

sub _setup_engine {
	$opts{engine} = shift || 'rig::engine::' . $opts{engine}
		unless $opts{engine} =~/\:\:/;
    eval "require $opts{engine};" or croak "rig: " . $@;
    return $opts{engine} . '::import';
}

sub _setup_parser {
	$opts{parser} = 'rig::parser::' . $opts{parser}
		unless $opts{parser} =~/\:\:/;
    eval "require $opts{parser};" or croak "rig: " . $@;
}

=head1 SYNOPSIS


	use rig common; # uses Data::Dumper and List::Utils

	print first { $_ > 10 } @ary; # from List::Utils;
	print Dumper $foo;  # from Data::Dumper

In your C</home/user/.rig> yaml file:

	- common:
		- List::Utils:
			- first
			- max
		- Data::Dumper
			
=head1 DESCRIPTION


    use rig -file => '/tmp/.rig';
    use rig -path => qw(. /home/me /opt);
    use rig -engine => 'base';
	use rig -jit => 1;

    use rig moose, strictness, modernity;

    use rig 'kensho';
    use rig 'kensho::strictive';
    use rig 'signes';
	use rig 'debugging';

=head1 DESCRIPTION

This module allows you to organize and bundle your favorite modules, thus reducing 
the recurring task of C<use>ing them in your programs and import frequent. 

You can rig your bundles in 2 places:

* A .rig file in your home or current directory.
* Packages undeneath the rig::bundle::<bundle_name>

=head1 IMPLEMENTATION

This module uses lots of C<goto>s to trick modules to think they're being loaded
by the original caller, and not by C<rig> itself. 

Modules that don't have an C<import()> method, are instead C<eval>led into the caller's package. 

I'm always open to suggestions on how to make loading modules more generic and effective.

=head1 The .perlrig file

The .perlrig file is where you keep your favorite rigs. It could have had lots 
of space to put your funky startup code, but it doesn't.

Having a structured file written in plain yaml makes it easier for worldly parsers
to parse the file and understand your configuration.

Although this distribution only comes with a yaml parser for the .perlrig file.
you can still write your own parser if you like:

	package rig::parser::xml;
	use base 'rig::parser::base';

	sub parse { return .... } 

	# meanwhile in Gotham City:
	package main;
	use rig -parser => 'xml';
	use rig 'fav-in-xml';
	
=head1 rig::task:: modules

A more distribution-friendly way of wiring up module bundles for your application is
to ship them as part of the C<rig::task::> namespace. 

	package rig::task::myfav;

	sub bundle {
		return {
			modules => [qw/strict warnings Data::Dumper/],
			also    => [qw/moosiness bobbys/]
		}
	}

=cut

1;
