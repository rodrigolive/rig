package rig::task::modern;

sub rig {
     return {
      use => [
         'strict',
         { 'warnings'=> [ 'FATAL','all' ] }
      ]
   };
}

1;
