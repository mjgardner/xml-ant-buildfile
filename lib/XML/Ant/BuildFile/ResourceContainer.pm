package XML::Ant::BuildFile::ResourceContainer;

# ABSTRACT: Container for XML::Ant::BuildFile::Resource plugins

=head1 DESCRIPTION

Base class for containers of multiple
L<XML::Ant::BuildFile::Resource|XML::Ant::BuildFile::Resource> plugins.

=head1 SYNOPSIS

    package XML::Ant::BuildFile::Resource::Foo;
    use Moose;
    extends 'XML::Ant::BuildFile::ResourceContainer';

=cut

use utf8;
use Modern::Perl '2010';    ## no critic (Modules::ProhibitUseQuotedVersion)

# VERSION
use English '-no_match_vars';
use List::Util 1.33 'any';
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
    my %isa_map
        = map { lc( ( split /::/ )[-1] ) => $_ } $self->resource_plugins;
    $self->meta->add_attribute(
        _resources => (
            traits      => [qw(XPathObjectList Array)],
            xpath_query => join( q{|} => map {".//$_"} keys %isa_map ),
            isa_map     => \%isa_map,
            handles     => {
                all_resources    => 'elements',
                resource         => 'get',
                map_resources    => 'map',
                filter_resources => 'grep',
                find_resource    => 'first',
                num_resources    => 'count',
            },
        ),
    );
    return;
}

=method resources

Given one or more resource type names, returns a list of objects.

=cut

sub resources {
    my ( $self, @names ) = @_;
    return $self->filter_resources(
        sub {
            my $resource = $_;
            any { $_ eq $resource->resource_name } @names;
        },
    );
}

no Moose;

1;
