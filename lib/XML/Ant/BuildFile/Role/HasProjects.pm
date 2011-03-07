package XML::Ant::BuildFile::Role::HasProjects;

# ABSTRACT: Compose a collection of Ant build file projects

use strict;
use Carp;
use English '-no_match_vars';
use Moose::Role;
use MooseX::Has::Sugar;
use MooseX::Types::Moose 'HashRef';
use MooseX::Types::Path::Class 'Dir';
use Path::Class;
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use TryCatch;
use XML::Ant::BuildFile::Project;
use namespace::autoclean;

=attr working_copy

A L<Path::Class::Dir|Path::Class::Dir> to search for L</projects>.

=cut

has working_copy => ( rw, required, coerce,
    isa           => Dir,
    documentation => 'directory containing content',
);

=attr projects

Reference to an array of
L<XML::Ant::BuildFile::Project|XML::Ant::BuildFile::Project>s in the
current C<working_copy> directory.

=cut

has projects => ( rw,
    lazy_build,
    isa => HashRef ['XML::Ant::BuildFile::Project'],
    traits  => ['Hash'],
    handles => {
        project       => 'get',
        project_files => 'keys',
    },
);

sub _build_projects {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self = shift;
    my %projects;
    $self->working_copy->recurse(
        callback => _make_ant_finder_callback( \%projects ) );
    return \%projects;
}

sub _make_ant_finder_callback {
    my $projects_ref = shift;

    return sub {
        my $path = shift;

        # skip directories and non-XML files
        return if $path->is_dir or $path !~ / [.]xml \z/i;

        my @dir_list = $path->dir->dir_list;
        for ( 0 .. $#dir_list ) {    # skip symlinks
            return if -l file( @dir_list[ 0 .. $ARG ] )->stringify();
        }
        return if 'CVS' ~~ @dir_list or '.svn' ~~ @dir_list;   # skip SCM dirs

        # look for matching XML files but only carp if parse error
        my $error;
        try {
            ## no critic (ValuesAndExpressions::ProhibitAccessOfPrivateData)
            $projects_ref->{"$path"}
                = XML::Ant::BuildFile::Project->new( file => $path );
        }
        catch($error) { carp $error };
        return;
    };
}

1;

=head1 SYNOPSIS

    package My::Package;
    use Moose;
    with 'XML::Ant::BuildFile::Role::HasProjects';

    sub frobnicate_projects {
        my $self = shift;
        $self->working_copy('/dir/to/search');
        print "Found these projects:\n";
        print "$_\n" for @{$self->project_files};
    }

    1;

=head1 DESCRIPTION

This L<Moose::Role|Moose::Role> helps you compose a collection of Ant
project files found in a directory of source code.  The directory is searched
recursively for files ending in F<.xml>, skipping any symbolic links as well
as F<CVS> and Subversion F<.svn> directories.
