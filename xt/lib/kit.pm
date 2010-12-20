package kit;
use Hook::Scope;

sub import {
    my ($class, @args)=@_;
    my $pkg = caller;
    #eval "require strict;" or die $@;
    ##strict->import();
    #my $f = 'strict::import';
    #@_=('strict');
    #goto &$f;
    Hook::Scope::POST(sub {
        require strict;
        my $f = 'strict::import';
        strict->import();
        require Moose;
        Moose->import();
        #@_=('strict');
        #goto &$f;
    });
}

1;
