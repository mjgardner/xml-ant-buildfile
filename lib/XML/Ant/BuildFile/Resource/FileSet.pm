package XML::Ant::BuildFile::Resource::FileSet;

# ABSTRACT: Set of file resources in an Ant build file

use English '-no_match_vars';
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef Str);
use MooseX::Types::Path::Class qw(Dir File);
use Path::Class;
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use namespace::autoclean;
extends 'XML::Ant::BuildFile::Element::PatternSet';
with 'XML::Ant::BuildFile::Resource';

=method includes

Returns a list of include patterns from the FileSet's C<includes> attribute
and any nested C<< <include/> >> elements.

=cut

has _dir =>
    ( ro,
    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    isa         => Str,
    traits      => ['XPathValue'],
    xpath_query => './@dir',
    );

=attr dir

A L<Path::Class::Dir|Path::Class::Dir> for the root of the directory tree of
this FileSet.

=cut

has dir => ( ro, lazy,
    isa => Dir,
    default =>
        sub { dir( $ARG[0]->project->apply_properties( $ARG[0]->_dir ) ) },
);

has _files => ( ro, lazy_build,
    isa => ArrayRef [File],
    traits  => ['Array'],
    handles => { files => 'elements' },
);

sub _build__files
{    ## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
    my $self = shift;
    my @patterns;
    for my $pattern ( $self->includes ) {

        # translate Ant globs into regular expressions
        $pattern =~ s/ [*] /.*/;
        $pattern =~ s/ [?] /./;
        $pattern =~ s{ [/\\] \z}{**\\z};
        $pattern =~ s{ [*]{2} }{(?:(?:[^/]+)/)+};
        push @patterns, qr/$pattern/;
    }

    my @files;
    $self->dir->recurse(
        callback => sub {
            my $path = shift;
            return if $path->is_dir;
            if ( !@patterns ) { push @files, $path; return }
            for my $pattern (@patterns) {
                if ( $path->stringify() =~ $pattern ) {
                    push @files, $path;
                    return;
                }
            }
            return;
        }
    );
    return \@files;
}

__PACKAGE__->meta->make_immutable();
1;
