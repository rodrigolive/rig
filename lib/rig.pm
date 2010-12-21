package rig;
use strict;
use Carp;

our %opts = (
    engine => 'rig::engine::base',
    parser => 'rig::parser::yaml',
);

sub import {
    my $class = shift;
    my @args  = $class->_process_pragmas(@_);
    return if !@args and !exists $opts{'load'};

    # engine setup
    my $foo = $class->_setup_engine;

    # parser setup
    $class->_setup_parser;

    # go to the engine's import method
    return unless @args;
    my $instance = $opts{engine}->new(%opts);
    @_ = ( $instance, @args );
    goto &$foo;
}

sub _process_pragmas {
    my $class = shift;
    my @args;
    while ( my $_ = shift ) {
        if (/^-(.+)$/) {

            # process pragma
            my $next = shift;
            unshift( @_, $next ), $next = undef
              if defined $next && $next =~ /^-/;
            $opts{$1} = defined $next ? $next : 1;
        }
        else {
            push @args, $_;
        }
    }
    return @args;
}

sub _setup_engine {
    $opts{engine} = shift || 'rig::engine::' . $opts{engine}
      unless $opts{engine} =~ /\:\:/;
    eval "require $opts{engine};" or croak "rig: " . $@;
    return $opts{engine} . '::import';
}

sub _setup_parser {
    $opts{parser} = 'rig::parser::' . $opts{parser}
      unless $opts{parser} =~ /\:\:/;
    eval "require $opts{parser};" or croak "rig: " . $@;
}

1;

=head1 NAME

rig - Bundle up your favorite modules and imports into one call

=head1 SYNOPSIS

In your C</home/user/.perlrig> yaml file:

   common:
      use:
         - strict
         - warnings
         - List::Util:
            - first
            - max
         - Data::Dumper

Back in your code:

   use rig common;

   # same as:
   #   use strict;
   #   use warnings;
   #   use List::Util qw/first max/;
   #   use Data::Dumper;

   # now, have a ball:

   print first { $_ > 10 } @ary; # from List::Utils;
   print Dumper $foo;  # from Data::Dumper

=head1 DESCRIPTION

This module allows you to organize and bundle your favorite modules, thus reducing 
the recurring task of C<use>ing them in your programs, and implicitly requesting
imports by default. 

You can rig your bundles in 2 places:

=over

=item * 

A file called C<.perlrig> in your home or current working directory.

=item * 

Packages undeneath the rig::task::<rig_task_name>

=back

=head1 IMPLEMENTATION

This module uses lots of internal C<goto>s to trick modules to think they're being
loaded by the original caller, and not by C<rig> itself. And hooks to keep 
modules orderly loading. 

Modules that don't have an C<import()> method, are instead C<eval>led into the caller's package. 

This is a hacky, and I'm certainly open to suggestions on how to make
loading modules more generic and effective.

=head1 USAGE

=head2 Code

    use rig -file   => '/tmp/.rig';           # explicitly use a file
    use rig -path   => qw(. /home/me /opt);
    use rig -engine => 'base';
    use rig -jit    => 1;

    use rig moose, strictness, modernity;

    use rig 'kensho';
    use rig 'kensho::strictive';    # looks for rig::task::kensho::strictive
    use rig 'signes';
    use rig 'debugging';

=head2 C<.perlrig> YAML structure

   <task>:
      use:
         - <module> [min_version]
         - +<module> 
         - <module>:
            - <import1>
            - <import2>
            - ...
      also: <task2> [, <task3> ... ]

=head3 use section

=over

=item *

Lists modules to be C<use>d. 

=item *

Checks module versions.

=item *

Lists imports.

=back

By default, modules are imported by calling C<import>. Alternatively,
a plus sign C<+> can be used in front of the module to force
it to be loaded using the C<eval> method, as such:

    eval "package <your_package>; use <module>;"

This may be useful to workaround issues with using import when 
none is available, or things are just not working as expected.

=head3 also section

Used to bundle tasks into each other.

=head3 Examples

   moose:
      use:
         - Moose 0.92
         - Moose::Autobox
         - autodie
         - Method::Signatures
         - Try::Tiny
   goo:
      use:
         - strict
         - warnings
         - Data::Dumper
         - feature:
            - say
            - switch
         - Data::Alias
         - autodie
   bam:
      use:
         - List::Util:
            - first
            - max
            - min
         - Scalar::Util:
            - refaddr
         - Carp:
            - cluck
            - croak

=head1 The .perlrig file

The .perlrig file is where you keep your favorite rigs.

As mentioned earlier, C<rig> looks for a C<.perlrig> file in two
directories by default:

   * The current working directory.
   * Your home directory.

Important: only one rig file is loaded per C<perl> interpreter
instance. This will probably change in the future, as C<.perlrig>
file merging should be implemented.

=head2 Structure

It could have had room to put your funky startup code, but
it doesn't. This module is about order and parseability. 

Having a structured file written in plain yaml makes it easier for worldly parsers
to parse the file and understand your configuration.

=head2 Writing your own parser

Although this distribution only comes with a yaml parser for the .perlrig file.
you can still write your own parser if you like:

   package rig::parser::xml;
   use base 'rig::parser::base';

   sub parse { return .... } 

   # meanwhile in Gotham City:

   package main;
   use rig -parser => 'xml';
   use rig 'fav-in-xml';

=head2 Global settings

Use the C<$ENV{PERLRIG_FILE}> variable to tell C<rig> where to find your file.

   $ export PERLRIG_FILE=/etc/myrig
   $ perl foo_that_rigs.pl
   
=head1 rig::task:: modules

A more distribution-friendly way of wiring up module bundles for your application is
to ship them as part of the C<rig::task::> namespace. 

   package rig::task::myfav;

   sub rig {
        return {
         use => [
            'strict',
            { 'warnings'=> [ 'FATAL','all' ] }
         ],
         also => 'somethingelse',
      };
   }

This is the recommended way to ship a rig with your distribution. 

=head1 CAVEATS

Although short, the api and yaml specs are still unstable and are
subject to change. Mild thought has been put into it as to support
modifications without major deprecations.

=head2 Startup Cost

There's an upfront load time (on the first C<use rig> it finds) while C<rig>
looks for, parses and processes your C<.perlrig> file. Subsequent calls
won't look for any more files, as it's structure will remain loaded in memory.

=head2 Ordered Load

As of right now, module loading order tends to get messed up easily. This
will probably be fixed, as the author's intention is to load modules 
following the order set by the user in the C<.perlrig> and C<use rig>
statements.

=head1 TODO

=over

=item * 

Create a class to hold the perlrig definition.

=item *

Use L<Config::Any> or similar for more agnostic and advanced file loading.

=item * 

Straighten out and optimize internals.

=item * 

Test many more modules for edge cases.

=item * 

More verbs besides C<use> and C<also>, such as require, etc.

=item * 

A cookbook of some sort, with everyday examples.

=item * 

More tests.

=item * 

Fix load sequence.

=back 

=cut

