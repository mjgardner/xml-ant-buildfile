#!perl

use Test::Most tests => 1;
use English '-no_match_vars';
use Readonly;
use Path::Class;
use XML::Ant::BuildFile::Project;

my $project = XML::Ant::BuildFile::Project->new( file => 't/yui-build.xml' );

my %paths = $project->paths;

cmp_bag(
    [ keys %paths ],
    [qw(site.css.concat site.css.min site.js.concat site.js.min)],
    'path ids',
);
