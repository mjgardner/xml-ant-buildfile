#!perl

use English '-no_match_vars';
use Test::Most;
use Readonly;
use XML::Ant::BuildFile::Project;

my $tests;
Readonly my $PROJECT =>
    XML::Ant::BuildFile::Project->new( file => 't/yui-build.xml' );

my @concat_tasks = $PROJECT->target('concat-files')->tasks('concat');

my %concat_hash = map {
    $ARG->destfile->stringify() => map { $ARG->as_string }
        $ARG->all_resources
} @concat_tasks;
cmp_deeply(
    \%concat_hash,
    {   't/target/yui/concat/site.css' =>
            't/css/one.css t/css/two.css t/images/three.css',
        't/target/yui/concat/site.js' =>
            't/js/one.js t/js/two.js t/images/three.js',
    },
    'concat',
) or explain \%concat_hash;
$tests++;

done_testing($tests);
