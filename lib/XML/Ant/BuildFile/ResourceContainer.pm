package XML::Ant::BuildFile::ResourceContainer;

# ABSTRACT: Container for XML::Ant::BuildFile::Resource plugins

use English '-no_match_vars';
## no critic (Subroutines::ProhibitCallsToUndeclaredSubs)
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
                map_resources    => 'map',
                filter_resources => 'grep',
                find_resource    => 'first',
                num_resources    => 'count',
            },
        ),
    );
    return;
}

sub resources {
    my ( $self, @names ) = @ARG;
    return $self->filter_resources(
        sub {
            my $resource = $_;
            any { $_ eq $resource->resource_name } @names;
        },
    );
}

no Moose;

1;

__END__

=head1 SYNOPSIS

    package XML::Ant::BuildFile::Resource::Foo;
    use Moose;
    extends 'XML::Ant::BuildFile::ResourceContainer';

=head1 DESCRIPTION

Base class for containers of multiple
L<XML::Ant::BuildFile::Resource|XML::Ant::BuildFile::Resource> plugins.

=method BUILD

Automatically run after object construction to set up task object support.

=method resources

Given one or more resource type names, returns a list of objects.
