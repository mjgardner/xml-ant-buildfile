package XML::Ant::BuildFile::TaskContainer;

use English '-no_match_vars';
use Moose;
use Module::Pluggable (
    sub_name    => 'task_plugins',
    search_path => 'XML::Ant::BuildFile::Task',
    require     => 1,
);
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)

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
        $self->task_plugins;
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
