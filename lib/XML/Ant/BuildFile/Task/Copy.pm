package XML::Ant::BuildFile::Task::Copy;

# ABSTRACT: copy task node in an Ant build file

use English '-no_match_vars';
use Moose;
use MooseX::Types::Moose 'Str';
use MooseX::Has::Sugar;
use MooseX::Types::Path::Class 'File';
use Path::Class;
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use namespace::autoclean;
with 'XML::Ant::BuildFile::Task';

has _to_file =>
    ( ro,
    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    isa         => Str,
    traits      => ['XPathValue'],
    xpath_query => './@tofile',
    );

=attr to_file

The file to copy to as a L<Path::Class::File|Path::Class::File> object.

=cut

has to_file => ( ro, lazy,
    isa => File,
    default =>
        sub { dir( $ARG[0]->project->apply_properties( $ARG[0]->_to_file ) ) }
    ,
);

=method BUILD

Automatically run after object construction to set up task object support.

=cut

sub BUILD {
    my $self = shift;

    ## no critic (ValuesAndExpressions::ProhibitMagicNumbers)
    my %isa_map = map { lc( ( split /::/ => $ARG )[-1] ) => $ARG }
        $self->project->resource_plugins;
    $self->meta->add_attribute(
        _tasks => (
            traits      => [qw(XPathObjectList Array)],
            xpath_query => join( q{|} => map {".//$ARG"} keys %isa_map ),
            isa_map     => \%isa_map,
            handles     => {
                all_resources    => 'elements',
                resource         => 'get',
                filter_resources => 'grep',
                num_resources    => 'count',
            },
        )
    );
    return;
}

=method resources

Given one or more resource type names, returns a list of objects.

=cut

sub resources {
    my ( $self, @names ) = @ARG;
    return $self->filter_resources( sub { $ARG->resource_name ~~ @names } );
}

__PACKAGE__->meta->make_immutable();
1;

__END__
