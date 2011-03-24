#!perl

use Test::Most tests => 8;
use English '-no_match_vars';
use Readonly;
use Path::Class;
use XML::Ant::BuildFile::Project;

our $CLASS;

BEGIN {
    Readonly our $CLASS => 'XML::Ant::BuildFile::Project';
    eval "require $CLASS; $CLASS->import()";
}
Readonly my $TESTFILE => file('t/filelist.xml');

my $project
    = new_ok( $CLASS => [ file => $TESTFILE ], 'from Path::Class::File' );
$project = new_ok(
    $CLASS => [ file => $TESTFILE->stringify() ],
    'from path string',
);

is( $project->name, 'test', 'project name' );
cmp_bag(
    [ keys %{ $project->targets } ],
    [qw(simple double nested)],
    'target names',
);

my @filelists = @{ $project->filelists };
is( scalar @filelists, 3, 'filelists' );

cmp_deeply(
    [ map { $ARG->id } @filelists ],
    [ ('filelist') x 3 ],
    'filelist ids',
);

cmp_deeply(
    [ map { $ARG->directory->stringify() } @filelists ],
    [ (q{.}) x 3 ],
    'filelist dirs',
);

cmp_deeply( [ map { $ARG->stringify() } map { @{ $ARG->files } } @filelists ],
    [ map {"./$ARG"} qw(a a b a b) ], 'files' );
