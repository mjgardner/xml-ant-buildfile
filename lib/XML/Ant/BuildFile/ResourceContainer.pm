package XML::Ant::BuildFile::ResourceContainer;

# ABSTRACT: Container for XML::Ant::BuildFile::Resource plugins

use English '-no_match_vars';
use Moose;
use Module::Pluggable (
    sub_name    => 'resource_plugins',
    search_path => 'XML::Ant::BuildFile::Resource',
    require     => 1,
);
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)

=method BUILD

Automatically run after object construction to set up task object support.

=cut

sub BUILD {
    my $self = shift;

    ## no critic (ValuesAndExpressions::ProhibitMagicNumbers)
    my %isa_map = map { lc( ( split /::/ => $ARG )[-1] ) => $ARG }
        $self->resource_plugins;
    $self->meta->add_attribute(
        _resources => (
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

1;
