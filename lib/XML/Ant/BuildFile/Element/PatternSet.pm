package XML::Ant::BuildFile::Element::PatternSet;

# ABSTRACT: Set of patterns in an Ant build file

use English '-no_match_vars';
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef Maybe Str);
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
with 'XML::Ant::BuildFile::Role::InProject';

=attr id

C<< <id/ >> attribute of the C<< <patternset/> >>

=cut

{
    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    my %str_attr = (
        id             => './@id',
        _includes_attr => './@includes',
    );

    while ( my ( $attr, $xpath ) = each %str_attr ) {
        has $attr => ( ro,
            isa         => Str,
            traits      => ['XPathValue'],
            xpath_query => $xpath,
        );
    }

    has _includes_nested => ( ro,
        isa => ArrayRef [Str],
        traits      => ['XPathValueList'],
        xpath_query => './include/@name',
    );
}

=method includes

Returns a list of include patterns from the PatternSet's C<includes> attribute
and any nested C<< <include/> >> elements.

=cut

has _includes => ( ro, lazy_build,
    isa => ArrayRef [ Maybe [Str] ],
    traits  => ['Array'],
    handles => { includes => 'elements' },
);

sub _build_includes
{    ## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
    my $self = shift;
    my @includes;
    if ( defined $self->_includes_attr ) {
        push @includes, split / [\s,] /,
            $self->project->apply_properties( $self->_includes_attr );
    }
    if ( defined $self->_includes_nested ) {
        push @includes,
            map { $self->project->apply_properties($ARG) }
            @{ $self->_includes_nested };
    }
    return \@includes;
}

__PACKAGE__->meta->make_immutable();
1;
