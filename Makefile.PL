use 5.006;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Net::Pachube',
    VERSION_FROM      => 'lib/Net/Pachube.pm', # finds $VERSION
    PREREQ_PM         =>
              {
               'LWP::UserAgent' => 0,
               'XML::Simple' => 0,
              }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Net/Pachube.pm', # retrieve abstract from module
       AUTHOR         => 'Mark Hindess <soft-pachube@temporalanomaly.com>') : ()),
);

# append some extra local targets to the Makefile if Makefile.local exists
open my $f, "<Makefile.local" or exit(0);
open my $m, ">>Makefile" or exit(0);
while (<$f>) {
  print $m $_;
}
close $m;
close $f;
