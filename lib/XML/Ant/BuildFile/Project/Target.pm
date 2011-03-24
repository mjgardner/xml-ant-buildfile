package XML::Ant::BuildFile::Project::Target;

# ABSTRACT: target node within an Ant build file

use English '-no_match_vars';
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef Str);
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use namespace::autoclean;
with 'XML::Rabbit::Node' => { -version => '0.0.4' };

=attr project

Reference to the L<XML::Ant::BuildFile::Project|XML::Ant::BuildFile::Project>
at the root of the build file containing this target.

=cut

has project => (
    isa         => 'XML::Ant::BuildFile::Project',
    traits      => ['XPathObject'],
    xpath_query => q{/},
);

=attr name

Name of the target.

=cut

{
## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
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
}

=attr

If the target has any dependencies, this will return them as an array reference
of L<XML::Ant::BuildFile::Project::Target|XML::Ant::BuildFile::Project::Target>
objects.

=cut

has dependencies => ( ro, lazy_build, isa => ArrayRef [__PACKAGE__] );

sub _build_dependencies {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self = shift;
    return if not $self->_has_depends or not $self->_depends;

    return [
        map { $self->project->get_target($ARG) } split /,/,
        $self->_depends,
    ];
}

__PACKAGE__->meta->make_immutable();
1;

__END__

=head1 SYNOPSIS

    use XML::Ant::BuildFile::Project;

    my $project = XML::Ant::BuildFile::Project->new( file => 'build.xml' );
    for my $target ( values %{$project->targets} ) {
        print 'got target: ', $target->name, "\n";
    }

=head1 DESCRIPTION

See L<XML::Ant::BuildFile::Project|XML::Ant::BuildFile::Project> for a complete
description.
