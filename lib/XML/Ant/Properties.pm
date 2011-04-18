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

around set => sub {
    my ( $orig, $self ) = splice @ARG, 0, 2;
    my %element  = @ARG;
    my %property = %{ $self->_properties };
    while ( my ( $key, $value ) = each %element ) {
        $property{$key} = $self->apply($value);
    }
    $self->_properties( \%property );
    return $self->$orig(%element);
};

=method apply

Takes a string and applies property substitution to it.

=cut

sub apply {
    my ( $self, $source ) = @ARG;
    my %property = %{ $self->_properties };
    while ( $source =~ / \$ { [\w:.]+ } / ) {
        my $old_source = $source;
        while ( my ( $property, $value ) = each %property ) {
            $source =~ s/ \$ {$property} /$value/g;
        }
        last if $old_source eq $source;
    }
    return $source;
}

__PACKAGE__->meta->make_immutable();
1;
