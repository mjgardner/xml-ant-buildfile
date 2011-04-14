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

has _location => (
    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    isa         => Str,
    traits      => ['XPathValue'],
    xpath_query => './@location',
);

has _paths => ( ro, lazy_build,
    isa => ArrayRef [ Dir | File ],
    traits  => ['Array'],
    handles => { all => 'elements' },
);

sub _build__paths {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self = shift;
    my @paths;

    if ( $self->_location ) {
        push @paths,
            file( $self->project->apply_properties( $self->_location ) );
    }
    push @paths, map { $ARG->files } $self->resources('filelist');

    return \@paths;
}

1;
