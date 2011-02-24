package XML::Ant::BuildFile::Project::FileList;

use English '-no_match_vars';
use Path::Class;
use Regexp::DefaultFlags;

use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef HashRef Str);
use MooseX::Types::Path::Class qw(Dir File);
use namespace::autoclean;
with 'XML::Rabbit::Node';

has project => (
    isa         => 'XML::Ant::BuildFile::Project',
    traits      => ['XPathObject'],
    xpath_query => '/',
    handles     => ['properties'],
);

has _dir_attr =>
    ( isa => Str, traits => [qw(XPathValue)], xpath_query => './@dir' );
has id => ( isa => Str, traits => [qw(XPathValue)], xpath_query => './@id' );

has directory => ( ro, lazy,
    isa      => Dir,
    init_arg => undef,
    default  => sub { dir( $ARG[0]->_property_subst( $ARG[0]->_dir_attr ) ) },
);

has _file_names => (
    isa => ArrayRef [Str],
    traits      => ['XPathValueList'],
    xpath_query => './file/@name',
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

no Moose;
__PACKAGE__->meta->make_immutable();
1;
