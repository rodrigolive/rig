BEGIN {
    sub rig::task::t_imports::use {
        { use => [
            { 'List::Util'=> [ 'sum','max' ] },
            { 'List::MoreUtils'=> [ 'any','firstval' ] }
        ] }
    };
}

use Test::More;
use rig -file => 't/.perlrig';
use rig 't_imports';

is( sum(1..10), 55, 'sum' );
is( max(1..10), 10, 'max' );
is( do { firstval { $_ eq 10 } 1..20 } , 10, 'firstval' );
ok( do { any { $_ eq 10 } 1..20 }, 'any' );

done_testing;
