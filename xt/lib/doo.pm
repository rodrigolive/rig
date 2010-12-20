package doo;
use strict;
use autodie;

sub import {
    strict->import(); 
    autodie->import(); 
    eval "use autodie; use strict";
}


1;
