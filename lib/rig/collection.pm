package rig::collection;
use strict;
use warnings;

sub new {
    my ($class,%args)=@_;
    bless \%args, __PACKAGE__;
}



1;
