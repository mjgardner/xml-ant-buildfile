package XML::Ant::BuildFile::Resource::Path;

# ABSTRACT: Path-like structure in an Ant build file

use Modern::Perl;
use English '-no_match_vars';
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef Str);
use MooseX::Types::Path::Class qw(Dir File);
use Path::Class;
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use XML::Ant::Properties;
use namespace::autoclean;
extends 'XML::Ant::BuildFile::ResourceContainer';

has _paths => ( ro,
    lazy_build,
    isa => ArrayRef [ Dir | File ],
    traits  => ['Array'],
    handles => {
        all       => 'elements',
        as_string => [ join => $OSNAME =~ /\A MSWin/ ? q{;} : q{:} ],
    },
);

sub _build__paths {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self = shift;
    my @paths;

    if ( my $location = $self->_location ) {
        if ( not state $recursion_guard) {
            $recursion_guard = 1;
            $location        = XML::Ant::Properties->apply($location);
            undef $recursion_guard;
        }
        push @paths, file($location);
    }
    push @paths, map { $ARG->files } $self->resources('filelist');

    return \@paths;
}

with 'XML::Ant::BuildFile::Resource';

has _location => (
    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    isa         => Str,
    traits      => ['XPathValue'],
    xpath_query => './@location',
);

1;
