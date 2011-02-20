#!perl

use English '-no_match_vars';
use Test::Most tests => 5;
use Test::Moose;
use Readonly;
use XML::LibXML;
use Algorithm::Dependency;

our $CLASS;

BEGIN {
    Readonly our $CLASS => 'Algorithm::Dependency::Source::Ant::Buildfile';
    eval "require $CLASS; $CLASS->import();";
}

meta_ok($CLASS);
ok( (   grep { $ARG eq 'Algorithm::Dependency::Source' }
            $CLASS->meta->superclasses
    ),
    'isa Algorithm::Dependency::Source'
);

Readonly my $DIR      => '/path/to/files';
Readonly my $TEST_XML => <<"END_XML";
<?xml version="1.0"?>
<project name="test">
    <filelist id="list1" dir="$DIR">
        <file name="foo"/>
        <file name="bar"/>
    </filelist>
    <filelist id="list2" dir="$DIR">
        <file name="baz"/>
        <file name="faz"/>
    </filelist>
</project>
END_XML
my $source = new_ok(
    $CLASS => [ xml => XML::LibXML->load_xml( string => $TEST_XML ), ] );
my $dep = new_ok( 'Algorithm::Dependency' => [ source => $source ] );
my $schedule = $dep->schedule_all();
cmp_deeply(
    $schedule,
    [ ( sort map {"$DIR/$ARG"} qw(foo bar baz faz) ), qw(list1 list2), ],
    'dependency schedule'
) or explain $schedule;
