#use strict;
#use warnings;

use Test::More tests => 2;                      # last test to print

use rig -file => 't/.perlrig';

use rig '_t_perlrig';
is( eval '$var = 1 ', undef , 'strictness' ) ;

use rig '_t_perlrig_utils';
is( sum(1..10), 55, 'sum' );

