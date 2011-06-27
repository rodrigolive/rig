package rig::task::modern;

sub rig {
     return {
      use => [
         'strict',
         { 'warnings'=> [ 'FATAL','all' ] }
      ]
   };
}

=head1 NAME

rig::task::modern - standard modern Perl

=head1 DESCRIPTION

A basic Modern Perl setting:


    use strict;
    use warnings qw/FATAL all/;

=cut

1;
