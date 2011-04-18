#!perl

use Test::Most tests => 3;
use English '-no_match_vars';
use XML::Ant::BuildFile::Project;

my $project = XML::Ant::BuildFile::Project->new( file => 't/yui-build.xml' );
my $copy = ( $project->target('move-files')->tasks('copy') )[0];
isa_ok( $copy, 'XML::Ant::BuildFile::Task::Copy', 'copy task' );
my $filelist = ( $copy->resources('filelist') )[0];
isa_ok(
    $filelist,
    'XML::Ant::BuildFile::Resource::FileList',
    'file list to copy',
);
cmp_bag(
    [ $filelist->map_files( sub {"$ARG"} ) ],
    [   qw(t/target/yui/mincat/css/min/site.css
            t/target/yui/mincat/js/min/site.js),
    ],
    'names in file list',
);
