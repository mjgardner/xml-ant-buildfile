package XML::Ant::BuildFile::Task::Java;

# ABSTRACT: Java task node in an Ant build file

use Carp;
use English '-no_match_vars';
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef Str);
use MooseX::Types::Path::Class 'File';
use Path::Class;
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use namespace::autoclean;
with 'XML::Ant::BuildFile::Task';

=attr classname

A string representing the Java class that's executed.

=cut

my %xpath_attr = (
    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    classname  => './@classname',
    _jar       => './@jar',
    _args_attr => './@args',
);

while ( my ( $attr, $xpath ) = each %xpath_attr ) {
    has $attr => ( ro,
        isa         => Str,
        traits      => ['XPathValue'],
        xpath_query => $xpath,
    );
}

=attr jar

A L<Path::Class::File|Path::Class::File> for the jar file being executed.

=cut

has jar => ( ro, lazy,
    isa => File,
    default =>
        sub { file( $ARG[0]->project->apply_properties( $ARG[0]->_jar ) ) },
);

=method args

Returns a list of all arguments passed to the Java class.

=method arg

Given one or more index numbers, returns a list of those positional arguments.

=method arg_line

Returns a string of all the arguments joined together, separated by spaces.

=method map_args

Returns a list of arguments transformed by the given code reference.

=method filter_args

Returns a list of arguments for which the given code reference returns C<true>.

=method find_arg

Returns the first argument for which the given code reference returns C<true>.

=method num_args

Returns a count of all arguments.  Note that space-separated arguments such
as those produced by C<< <java args="..."/> >> and C<< <arg line="..."/> >>
will be split apart and count as separate arguments.

=cut

has _args_ref => ( ro,
    isa => ArrayRef [Str],
    traits      => [qw(XPathValueList Array)],
    xpath_query => './arg',
    handles     => { _all_args => 'elements', _filter_args => 'map' },
);

has _args => ( ro,
    lazy_build,
    isa => ArrayRef [Str],
    traits  => ['Array'],
    handles => {
        args        => 'elements',
        arg         => 'get',
        arg_line    => [ join => q{ } ],
        map_args    => 'map',
        filter_args => 'grep',
        find_arg    => 'first',
        num_args    => 'count',
    },
);

sub _build_args { ## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
    my $self = shift;

    my @nested_args = $self->_filter_args(
        sub {
            given ( shift->node ) {
                when ( $ARG->hasAttribute('value') ) {
                    return $ARG->getAttribute('value');
                }
                when ( $ARG->hasAttribute('line') ) {
                    return split / \s /, $ARG->getAttribute('line');
                }
            }
        }
    );

    return [ split( / \s /, $self->_args_attr ), @nested_args ];
}

__PACKAGE__->meta->make_immutable();
1;

__END__

=head1 SYNOPSIS

    use XML::Ant::BuildFile::Project;
    my $project = XML::Ant::BuildFile::Project->new( file => 'build.xml' );
    my @foo_java = $project->target('foo')->tasks('java');
    for my $java (@foo_java) {
        print $java->classname || "$java->jar";
        print "\n";
    }

=head1 DESCRIPTION

This is an incomplete class for
L<Ant Java task|http://ant.apache.org/manual/Tasks/java.html>s in a
L<build file project|XML::Ant::BuildFile::Project>.
