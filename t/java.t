#!perl

use Test::Most tests => 3;
use English '-no_match_vars';
use Readonly;
use Path::Class;
use XML::Ant::BuildFile::Project;

my $project = XML::Ant::BuildFile::Project->new( file => 't/java.xml' );

my $java = ( $project->target('testSpawn')->tasks('java') )[0];
ok( $java, 'java task' );
is( $java->classname, '${spawnapp}', 'classname' );
cmp_deeply( [ $java->args ], [ '${timeToWait}', '${logFile}' ], 'args' );
