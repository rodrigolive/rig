BEGIN {
    sub rig::task::t_imports::rig {
        { use => [
            { 'List::Util'=> [ 'sum','max' ] },
            { 'List::MoreUtils'=> [ 'any','firstval' ] }
        ] }
    };
}

use Test::More;

eval { require List::Util };
plan skip_all => "List::Util not installed" if $@; 

use FindBin '$Bin';
use rig -file => $Bin . '/perlrig';
use rig 't_imports';

is( sum(1..10), 55, 'sum' );
is( max(1..10), 10, 'max' );

eval { require List::MoreUtis };
plan skip_all => "List::MoreUtils not installed" if $@; 

is( do { firstval { $_ eq 10 } 1..20 } , 10, 'firstval' );
ok( do { any { $_ eq 10 } 1..20 }, 'any' );

done_testing;
