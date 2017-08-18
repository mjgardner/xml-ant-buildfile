package XML::Ant::BuildFile::Resource::FileList;

# ABSTRACT: file list node within an Ant build file

use utf8;
use Modern::Perl '2010';    ## no critic (Modules::ProhibitUseQuotedVersion)

# VERSION
use Modern::Perl;
use English '-no_match_vars';
use Path::Class;
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef HashRef Str);
use MooseX::Types::Path::Class qw(Dir File);
use XML::Ant::Properties;
use namespace::autoclean;

has directory => ( ro, required, lazy,
    builder  => '_build_directory',
    isa      => Dir,
    init_arg => undef,
);

sub _build_directory {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self      = shift;
    my $directory = $self->_dir_attr;

    if ( not state $recursion_guard) {
        $recursion_guard = 1;
        $directory       = XML::Ant::Properties->apply($directory);
        undef $recursion_guard;
    }
    return dir($directory);
}

has _files => ( ro, lazy,
    builder  => '_build__files',
    isa      => ArrayRef [File],
    traits   => ['Array'],
    init_arg => undef,
    handles  => {
        files        => 'elements',
        map_files    => 'map',
        filter_files => 'grep',
        find_file    => 'first',
        file         => 'get',
        num_files    => 'count',
        as_string    => [ join => q{ } ],
    },
);

sub _build__files
{    ## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
    my $self = shift;
    my @file_names;

    if ( defined $self->_file_names ) {
        push @file_names, @{ $self->_file_names };
    }
    if ( defined $self->_files_attr_names ) {
        push @file_names, split / [,\s]* /, $self->_files_attr_names;
    }

    if ( not state $recursion_guard) {
        $recursion_guard = 1;
        @file_names = map { XML::Ant::Properties->apply($_) } @file_names;
        undef $recursion_guard;
    }

    return [ map { $self->_prepend_dir($_) } @file_names ];
}

sub _prepend_dir {
    my ( $self, $file_name ) = @_;
    return $self->directory->subsumes( file($file_name) )
        ? file($file_name)
        : $self->directory->file($file_name);
}

has content =>
    ( ro, lazy, isa => ArrayRef [File], default => sub { $_[0]->_files } );

with 'XML::Ant::BuildFile::Resource';

{
## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)

    has _dir_attr => ( ro, required,
        isa         => Str,
        traits      => ['XPathValue'],
        xpath_query => './@dir',
    );

    has _file_names => ( ro,
        isa => ArrayRef [Str],
        traits      => ['XPathValueList'],
        xpath_query => './file/@name',
    );

    has _files_attr_names => ( ro,
        isa         => Str,
        traits      => ['XPathValue'],
        xpath_query => './@files',
    );
}

no Moose;

1;

__END__

=head1 SYNOPSIS

    use XML::Ant::BuildFile::Project;

    my $project = XML::Ant::BuildFile::Project->new( file => 'build.xml' );
    for my $list_ref (@{$project->file_lists}) {
        print 'id: ', $list_ref->id, "\n";
        print join "\n", @{$list_ref->files};
        print "\n\n";
    }

=head1 DESCRIPTION

See L<XML::Ant::BuildFile::Project|XML::Ant::BuildFile::Project> for a complete
description.

=attr directory

L<Path::Class::Dir|Path::Class::Dir> indicated by the C<< <filelist> >>
element's C<dir> attribute with all property substitutions applied.

=method files

Returns an array of L<Path::Class::File|Path::Class::File>s within
this file list with all property substitutions applied.
