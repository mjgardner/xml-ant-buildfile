package XML::Ant::BuildFile::Role::HasProjects;

# ABSTRACT: Compose a collection of Ant build file projects

use strict;
use Carp;
use English '-no_match_vars';
use List::Util 1.33 'any';
use Moose::Role;
use MooseX::Has::Sugar;
use MooseX::Types::Moose 'HashRef';
use MooseX::Types::Path::Class 'Dir';
use Path::Class;
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use Try::Tiny;
use XML::Ant::BuildFile::Project;
use namespace::autoclean;

has working_copy => ( rw, required, coerce,
    isa           => Dir,
    documentation => 'directory containing content',
);

has projects => ( rw, lazy,
    builder => '_build_projects',
    isa     => HashRef ['XML::Ant::BuildFile::Project'],
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
        return                       # skip SCM dirs
            if any { 'CVS' eq $_ } @dir_list
            or any { '.svn' eq $_ } @dir_list;

        # look for matching XML files but only carp if parse error
        ## no critic (ValuesAndExpressions::ProhibitAccessOfPrivateData)
        $projects_ref->{"$path"} = try {
            XML::Ant::BuildFile::Project->new( file => $path );
        }
        catch { carp $_ };
        return;
    };
}

no Moose::Role;

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

=attr working_copy

A L<Path::Class::Dir|Path::Class::Dir> to search for L</projects>.

=attr projects

Reference to an array of
L<XML::Ant::BuildFile::Project|XML::Ant::BuildFile::Project>s in the
current C<working_copy> directory.
