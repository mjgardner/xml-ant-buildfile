package XML::Ant::BuildFile::Task::Concat;

# ABSTRACT: concat task node in an Ant build file

use utf8;
use Modern::Perl '2010';    ## no critic (Modules::ProhibitUseQuotedVersion)

# VERSION
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

has _destfile =>
    ( ro,
    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    isa         => Str,
    traits      => ['XPathValue'],
    xpath_query => './@destfile',
    );

=attr destfile

The file to concatenate into as a L<Path::Class::File|Path::Class::File>
object.

=cut

has destfile => ( ro, lazy,
    isa => File,
    default =>
        sub { file( XML::Ant::Properties->apply( $_[0]->_destfile ) ) },
);

no Moose;

1;

__END__

=head1 SYNOPSIS

    package My::Ant;
    use Moose;
    with 'XML::Rabbit::Node';

    has paths => (
        isa         => 'ArrayRef[XML::Ant::BuildFile::Task::Concat]',
        traits      => 'XPathObjectList',
        xpath_query => './/concat',
    );

=head1 DESCRIPTION

This is a L<Moose|Moose> type class meant for use with
L<XML::Rabbit|XML::Rabbit> when processing C<< <concat/> >> tasks in an Ant
build file.
