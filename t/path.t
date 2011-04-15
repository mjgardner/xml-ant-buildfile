#!perl

use Test::Most tests => 5;
use English '-no_match_vars';
use Readonly;
use Path::Class;
use XML::Ant::BuildFile::Project;

my $project = XML::Ant::BuildFile::Project->new( file => 't/yui-build.xml' );

my %paths = $project->paths;

cmp_bag(
    [ keys %paths ],
    [   qw(site.css.concat
            site.js.concat
            site.css.min
            site.js.min),
    ],
    'path ids',
);

cmp_deeply(
    [   map {
            [ $ARG->[0] => [ map {"$ARG"} $ARG->[1]->all ] ]
            } $project->path_pairs,
    ],
    bag([ 'site.css.concat' => ['t/target/yui/concat/site.css'] ],
        [ 'site.js.concat'  => ['t/target/yui/concat/site.js'] ],
        [ 'site.css.min'    => ['t/target/yui/mincat/css/min/site.css'] ],
        [ 'site.js.min'     => ['t/target/yui/mincat/js/min/site.js'] ],
    ),
    'path location pairs',
);

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
