package XML::Ant::Properties;

# ABSTRACT: Singleton class for Ant properties

use strict;
use English '-no_match_vars';
use MooseX::Singleton;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(HashRef Str);
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use namespace::autoclean;

has _properties => ( rw,
    isa => HashRef [Str],
    init_arg => undef,
    traits   => ['Hash'],
    default  => sub { {} },
    handles  => {
        map { $ARG => $ARG }
            qw(count get set delete exists defined keys values clear),
    },
);

=method apply

Takes a string and applies property substitution to it.

=cut

sub apply {
    my ( $self, $source ) = @ARG;
    my %properties = %{ $self->_properties };
    while ( $source =~ / \$ { [\w:.]+ } / ) {
        while ( my ( $property, $value ) = each %properties ) {
            $source =~ s/ \$ {$property} /$value/g;
        }
    }
    return $source;
}

__PACKAGE__->meta->make_immutable();
1;
