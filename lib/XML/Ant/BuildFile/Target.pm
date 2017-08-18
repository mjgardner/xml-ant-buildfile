package XML::Ant::BuildFile::Target;

# ABSTRACT: target node within an Ant build file

=head1 DESCRIPTION

See L<XML::Ant::BuildFile::Project|XML::Ant::BuildFile::Project> for a complete
description.

=head1 SYNOPSIS

    use XML::Ant::BuildFile::Project;

    my $project = XML::Ant::BuildFile::Project->new( file => 'build.xml' );
    for my $target ( values %{$project->targets} ) {
        print 'got target: ', $target->name, "\n";
    }

=cut

use utf8;
use Modern::Perl '2010';    ## no critic (Modules::ProhibitUseQuotedVersion)

# VERSION
use English '-no_match_vars';
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef Str);
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use namespace::autoclean;
extends 'XML::Ant::BuildFile::TaskContainer';
with 'XML::Ant::BuildFile::Role::InProject';

=attr dependencies

If the target has any dependencies, this will return them as an array reference
of C<XML::Ant::BuildFile::Target> objects.

=cut

has dependencies => ( ro, lazy,
    builder => '_build_dependencies',
    isa     => ArrayRef [__PACKAGE__],
);

sub _build_dependencies {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self = shift;
    return if not $self->_has_depends or not $self->_depends;
    return [ map { $self->project->target($_) } split /,/, $self->_depends ];
}

## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)

=attr name

Name of the target.

=cut

has name => (
    isa         => Str,
    traits      => ['XPathValue'],
    xpath_query => './@name',
);

has _depends => (
    isa         => Str,
    traits      => ['XPathValue'],
    xpath_query => './@depends',
    predicate   => '_has_depends',
);

no Moose;

1;
