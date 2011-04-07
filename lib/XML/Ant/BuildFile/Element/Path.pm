package XML::Ant::BuildFile::Element::Path;

# ABSTRACT: Path-like structure in an Ant build file

use English '-no_match_vars';
use Moose;
use MooseX::Types::Moose 'ArrayRef';
use namespace::autoclean;
extends 'XML::Ant::BuildFile::ResourceContainer';
with 'XML::Rabbit::Node';

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

1;
