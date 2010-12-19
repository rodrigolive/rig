use Test::More tests => 2;                      # last test to print

use rig -file => 't/.perlrig';
use rig '_t_also';
ok( ref timethis( 10, sub{ '' }), 'also 1' );
ok( ref timethese( 10, sub{ '' }), 'also 1' );
