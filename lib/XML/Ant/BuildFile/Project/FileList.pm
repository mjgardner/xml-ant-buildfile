package XML::Ant::BuildFile::Project::FileList;

# ABSTRACT: file list node within an Ant build file

use English '-no_match_vars';
use Path::Class;
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef HashRef Str);
use MooseX::Types::Path::Class qw(Dir File);
use namespace::autoclean;
with 'XML::Rabbit::Node';

has project => (
    isa         => 'XML::Ant::BuildFile::Project',
    traits      => ['XPathObject'],
    xpath_query => q{/},
    handles     => ['properties'],
);

{
    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    my %attr = ( _dir_attr => './@dir', id => './@id' );
    for ( keys %attr ) {
        has $ARG => (
            isa         => Str,
            traits      => ['XPathValue'],
            xpath_query => $attr{$ARG},
        );
    }
    has _file_names => (
        isa => ArrayRef [Str],
        traits      => ['XPathValueList'],
        xpath_query => './file/@name',
    );
}

has directory => ( ro, lazy,
    isa      => Dir,
    init_arg => undef,
    default  => sub { dir( $ARG[0]->_property_subst( $ARG[0]->_dir_attr ) ) },
);

has files => ( ro, lazy,
    isa => ArrayRef [File],
    init_arg => undef,
    default  => sub {
        [   map { $ARG[0]->directory->file( $ARG[0]->_property_subst($ARG) ) }
                @{ $ARG[0]->_file_names }
        ];
    },
);

sub _property_subst {
    my ( $self, $source ) = @ARG;
    my %properties = %{ $self->properties };
    while ( my ( $property, $value ) = each %properties ) {
        $source =~ s/ \$ $property /$value/g;
    }
    return $source;
}

__PACKAGE__->meta->make_immutable();
1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION
