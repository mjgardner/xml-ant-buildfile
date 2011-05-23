#!perl

use Test::Most tests => 4;
use English '-no_match_vars';
use Path::Class;
use XML::Ant::BuildFile::Project;

my $project = XML::Ant::BuildFile::Project->new( file => 't/yui-build.xml' );
my $copy = ( $project->target('move-files')->tasks('copy') )[0];
isa_ok( $copy, 'XML::Ant::BuildFile::Task::Copy', 'copy task' );

is( $copy->to_dir->stringify(),
    XML::Ant::Properties->get('basedir'),
    'copy to_dir',
);

my $filelist = ( $copy->resources('filelist') )[0];
isa_ok(
    $filelist,
    'XML::Ant::BuildFile::Resource::FileList',
    'file list to copy',
);
cmp_bag(
    [ $filelist->map_files( sub {"$ARG"} ) ],
    [   map { unix_filestr_to_native("t/target/yui/mincat/$ARG") }
            qw(css/min/site.css js/min/site.js),
    ],
    'names in file list',
);

sub unix_filestr_to_native { file( split q{/}, $ARG[0] )->stringify() }
