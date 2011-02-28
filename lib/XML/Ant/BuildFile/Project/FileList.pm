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

=attr project

Reference to the L<XML::Ant::BuildFile::Project|XML::Ant::BuildFile::Project>
at the root of the build file containing this file list.

=method properties

Properties hash reference for the build file.

=cut

has project => (
    isa         => 'XML::Ant::BuildFile::Project',
    traits      => ['XPathObject'],
    xpath_query => q{/},
    handles     => ['properties'],
);

{
## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)

=attr id

C<id> attribute of this file list.

=cut

    my %xpath_attr = ( _dir_attr => './@dir', id => './@id' );
    while ( my ( $attr, $xpath ) = each %xpath_attr ) {
        has $attr =>
            ( isa => Str, traits => ['XPathValue'], xpath_query => $xpath );
    }

    has _file_names => (
        isa => ArrayRef [Str],
        traits      => ['XPathValueList'],
        xpath_query => './file/@name',
    );
}

=attr directory

L<Path::Class::Dir|Path::Class::Dir> indicated by the C<< <filelist> >>
element's C<dir> attribute with all property substitutions applied.

=cut

has directory => ( ro, lazy,
    isa      => Dir,
    init_arg => undef,
    default  => sub { dir( $ARG[0]->_property_subst( $ARG[0]->_dir_attr ) ) },
);

=attr files

Reference to an array of L<Path::Class::File|Path::Class::File>s within
this file list with all property substitutions applied.

=cut

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
        $source =~ s/ \$ {$property} /$value/g;
    }
    return $source;
}

__PACKAGE__->meta->make_immutable();
1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION
