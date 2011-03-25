package XML::Ant::BuildFile::Target;

# ABSTRACT: target node within an Ant build file

use English '-no_match_vars';
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef Str);
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use XML::Ant::BuildFile::Task::Java;
use namespace::autoclean;
with 'XML::Ant::BuildFile::Role::InProject';

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

=attr dependencies

If the target has any dependencies, this will return them as an array reference
of L<XML::Ant::BuildFile::Target|XML::Ant::BuildFile::Target>
objects.

=cut

has dependencies => ( ro, lazy_build, isa => ArrayRef [__PACKAGE__] );

sub _build_dependencies {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self = shift;
    return if not $self->_has_depends or not $self->_depends;
    return [ map { $self->project->target($ARG) } split /,/,
        $self->_depends ];
}

=method all_tasks

Returns an array of task objects contained in this target.

=method task

Given an index number returns that task from the target.

=method filter_tasks

Returns all task objects for which the given code reference returns C<true>.

=method num_tasks

Returns a count of the number of tasks in this target.

=method BUILD

Automatically run after object construction to set up task object support.

=cut

sub BUILD {
    my $self = shift;

    ## no critic (ValuesAndExpressions::ProhibitMagicNumbers)
    my %isa_map = map { lc( ( split /::/ => $ARG )[-1] ) => $ARG }
        $self->project->task_plugins;
    $self->meta->add_attribute(
        _tasks => (
            traits      => [qw(XPathObjectList Array)],
            xpath_query => join( q{|} => map {".//$ARG"} keys %isa_map ),
            isa_map     => \%isa_map,
            handles     => {
                all_tasks    => 'elements',
                task         => 'get',
                filter_tasks => 'grep',
                num_tasks    => 'count',
            },
        )
    );
    return;
}

=method tasks

Given one or more task names, returns a list of task objects.

=cut

sub tasks {
    my ( $self, @names ) = @ARG;
    return $self->filter_tasks( sub { $ARG->task_name ~~ @names } );
}

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
