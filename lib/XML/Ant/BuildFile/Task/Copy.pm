package XML::Ant::BuildFile::Task::Copy;

# ABSTRACT: copy task node in an Ant build file

use English '-no_match_vars';
use Moose;
use MooseX::Types::Moose 'Str';
use MooseX::Has::Sugar;
use MooseX::Types::Path::Class 'File';
use Path::Class;
use namespace::autoclean;
extends 'XML::Ant::BuildFile::ResourceContainer';
with 'XML::Ant::BuildFile::Task';

has _to_file =>
    ( ro,
    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    isa         => Str,
    traits      => ['XPathValue'],
    xpath_query => './@tofile',
    );

=attr to_file

The file to copy to as a L<Path::Class::File|Path::Class::File> object.

=cut

has to_file => ( ro, lazy,
    isa => File,
    default =>
        sub { dir( $ARG[0]->project->apply_properties( $ARG[0]->_to_file ) ) }
    ,
);

1;

__END__
