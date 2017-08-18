package XML::Ant::BuildFile::TaskContainer;

# ABSTRACT: Container for XML::Ant::BuildFile::Task plugins

use English '-no_match_vars';
use List::Util 1.33 'any';
use Moose;
use Module::Pluggable (
    sub_name    => 'task_plugins',
    search_path => 'XML::Ant::BuildFile::Task',
    require     => 1,
);
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)

sub BUILD {
    my $self = shift;

    ## no critic (ValuesAndExpressions::ProhibitMagicNumbers)
    my %isa_map
        = map { lc( ( split /::/ )[-1] ) => $_ } $self->task_plugins;
    $self->meta->add_attribute(
        _tasks => (
            traits      => [qw(XPathObjectList Array)],
            xpath_query => join( q{|} => map {".//$_"} keys %isa_map ),
            isa_map     => \%isa_map,
            handles     => {
                all_tasks    => 'elements',
                task         => 'get',
                filter_tasks => 'grep',
                find_task    => 'first',
                num_tasks    => 'count',
            },
        ),
    );
    return;
}

sub tasks {
    my ( $self, @names ) = @_;
    return $self->filter_tasks(
        sub {
            my $task = $_;
            any { $_ eq $task->task_name } @names;
        },
    );
}

no Moose;

1;

__END__

=head1 SYNOPSIS

    package XML::Ant::BuildFile::Task::Foo;
    use Moose;
    extends 'XML::Ant::BuildFile::TaskContainer';

=head1 DESCRIPTION

Base class for containers of multiple
L<XML::Ant::BuildFile::Task|XML::Ant::BuildFile::Task> plugins.

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

=method tasks

Given one or more task names, returns a list of task objects.
