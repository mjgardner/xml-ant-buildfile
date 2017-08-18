package XML::Ant::BuildFile::Resource::Path;

# ABSTRACT: Path-like structure in an Ant build file

=head1 DESCRIPTION

This is a L<Moose|Moose> type class meant for use with
L<XML::Rabbit|XML::Rabbit> when processing path-like structures in an Ant
build file.

=head1 SYNOPSIS

    package My::Ant;
    use Moose;
    with 'XML::Rabbit::RootNode';

    has paths => (
        isa         => 'HashRef[XML::Ant::BuildFile::Resource::Path]',
        traits      => 'XPathObjectMap',
        xpath_query => '//classpath[@id]|//path[@id]',
        xpath_key   => './@id',
    );

=cut

use utf8;
use Modern::Perl '2010';    ## no critic (Modules::ProhibitUseQuotedVersion)

# VERSION
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

has _paths => ( ro, lazy,
    builder => '_build__paths',
    isa    => ArrayRef [ Dir | File ], ## no critic (ProhibitBitwiseOperators)
    traits => ['Array'],
    handles => {

=method all

=cut

        all => 'elements',

=method as_string

=cut

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
    push @paths, map { $_->files } $self->resources('filelist');

    return \@paths;
}

has content => ( ro, lazy,
    isa => ArrayRef [ Dir | File ],    ## no critic (ProhibitBitwiseOperators)
    default => sub { $_[0]->_paths },
);

with 'XML::Ant::BuildFile::Resource';

has _location => (
    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    isa         => Str,
    traits      => ['XPathValue'],
    xpath_query => './@location',
);

no Moose;

1;
