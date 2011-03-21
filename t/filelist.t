#!perl

use Test::More tests => 4;
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
cmp_ok( $project->targets, '~~', [qw(simple double nested)], 'target names' );
