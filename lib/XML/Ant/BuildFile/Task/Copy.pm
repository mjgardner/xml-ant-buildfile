package XML::Ant::BuildFile::Task::Copy;

# ABSTRACT: copy task node in an Ant build file

use English '-no_match_vars';
use Moose;
use MooseX::Types::Moose 'Str';
use MooseX::Has::Sugar;
use MooseX::Types::Path::Class 'File';
use Path::Class;
use XML::Ant::Properties;
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
        sub { dir( XML::Ant::Properties->apply( $ARG[0]->_to_file ) ) },
);

1;

__END__

=head1 SYNOPSIS

    package My::Ant;
    use Moose;
    with 'XML::Rabbit::Node';

    has paths => (
        isa         => 'ArrayRef[XML::Ant::BuildFile::Task::Copy]',
        traits      => 'XPathObjectList',
        xpath_query => './/copy',
    );

=head1 DESCRIPTION

This is a L<Moose|Moose> type class meant for use with
L<XML::Rabbit|XML::Rabbit> when processing copy tasks in an Ant build file.
