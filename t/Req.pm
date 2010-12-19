package Req;
use Inline C;

sub import {
    hello();
}

1;
__DATA__
__C__

void hello() {
    printf("%s", "hellooooo" );
}
