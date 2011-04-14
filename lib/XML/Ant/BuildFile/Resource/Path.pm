package XML::Ant::BuildFile::Resource::Path;

# ABSTRACT: Path-like structure in an Ant build file

use English '-no_match_vars';
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef Str);
use MooseX::Types::Path::Class qw(Dir File);
use Path::Class;
use namespace::autoclean;
extends 'XML::Ant::BuildFile::ResourceContainer';
with 'XML::Ant::BuildFile::Resource';

has _elements => (
    isa         => ArrayRef,
    traits      => ['XPathValueList'],
    xpath_query => join(
        q{|} => map { ( "./\@$ARG", "./pathelement/\@$ARG" ) }
            qw(path location),
    ),
);

has _collections => (
    isa    => 'ArrayRef[XML::Ant::BuildFile::Resource]',
    traits => ['XPathObjectList'],
    xpath_query =>
        join( q{|} => map {"./$ARG"} qw(filelist path fileset dirset) ),
);

has _location => (
    isa         => Str,
    traits      => ['XPathValue'],
    xpath_query => './@location',
);

1;
