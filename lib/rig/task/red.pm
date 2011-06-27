package rig::task::red;

sub rig {
     return {
      use => [
         'strict',
         { 'warnings'=> [ 'FATAL','all' ] },
         '+IO::All',
         { 'feature' => ['say'] },
         { 'Data::Dumper' => ['Dump dd'] },
         'Try::Tiny',
         'Path::Class',
         'autobox::Core'
      ]
   };
}

1;
