package XML::Ant::BuildFile::Project;

# ABSTRACT: consume Ant build files

=head1 DESCRIPTION

This class uses L<XML::Rabbit|XML::Rabbit> to consume Ant build files using
a L<Moose|Moose> object-oriented interface.  It is a work in progress and in no
way a complete implementation of all Ant syntax.

=head1 SYNOPSIS

    use XML::Ant::BuildFile::Project;

    my $project = XML::Ant::BuildFile::Project->new( file => 'build.xml' );
    print 'Project name: ', $project->name, "\n";
    print "File lists:\n";
    for my $list_ref (@{$project->file_lists}) {
        print 'id: ', $list_ref->id, "\n";
        print join "\n", @{$list_ref->files};
        print "\n\n";
    }

=cut

use utf8;
use Modern::Perl '2010';    ## no critic (Modules::ProhibitUseQuotedVersion)

# VERSION
use English '-no_match_vars';
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Has::Sugar::Minimal;
use MooseX::Types::Moose qw(ArrayRef HashRef Str);
use MooseX::Types::Path::Class 'File';
use Path::Class;
use Readonly;
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
extends 'XML::Ant::BuildFile::ResourceContainer';
with 'XML::Rabbit::RootNode';

=attr file

On top of L<XML::Rabbit|XML::Rabbit>'s normal behavior, this class will also
coerce L<Path::Class::File|Path::Class::File> objects to the strings expected
by L<XML::Rabbit::Role::Document|XML::Rabbit::Role::Document>.

=cut

subtype 'FileStr', as Str;
coerce 'FileStr', from File, via {"$_"};
has '+_file' => ( isa => 'FileStr', coerce => 1 );

=method BUILD

After construction, the app-wide L<XML::Ant::Properties|XML::Ant::Properties>
singleton stores any C<< <property/> >> name/value pairs set by the build file,
as well as any resource string expansions handled by
L<XML::Ant::BuildFile::Resource|XML::Ant::BuildFile::Resource> plugins.
It also contains the following predefined properties as per the Ant
documentation:

=over

=item os.name

=item basedir

=item ant.file

=item ant.project.name

=back

=cut

sub BUILD {
    my $self = shift;

    my %ant_property = (
        'os.name'          => $OSNAME,
        'basedir'          => file( $self->_file )->dir->stringify(),
        'ant.file'         => $self->_file,
        'ant.project.name' => $self->name,
    );
    for my $property (
        grep { not XML::Ant::Properties->exists($_) }
        keys %ant_property
        )
    {
        XML::Ant::Properties->set( $property => $ant_property{$property} );
    }
    if ( keys %{ $self->_properties } ) {
        XML::Ant::Properties->set( %{ $self->_properties } );
    }

    for my $attr ( $self->meta->get_all_attributes() ) {
        next if !$attr->has_type_constraint;
        if ( $attr->type_constraint->name
            =~ /XML::Ant::BuildFile::Resource::/ )
        {
            my $attr_name = $attr->name;
            $attr_name = $self->$attr_name;
        }
    }
    return;
}

## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)

=attr name

Name of the Ant project.

=cut

has name => (
    isa         => Str,
    traits      => ['XPathValue'],
    xpath_query => '/project/@name',
);

has _properties => (
    lazy        => 1,
    isa         => HashRef [Str],
    traits      => ['XPathValueMap'],
    xpath_query => '//property[@name and @value]',
    xpath_key   => './@name',
    xpath_value => './@value',
    default     => sub { {} },
);

has _filelists => (
    isa         => 'ArrayRef[XML::Ant::BuildFile::Resource::FileList]',
    traits      => [qw(XPathObjectList Array)],
    xpath_query => '//filelist[@id]',
    handles     => {

=method filelists

Returns an array of all L<filelist|XML::Ant::BuildFile::Resource::FileList>s
in the project.

=cut

        filelists => 'elements',

=method filelist

Given an index number returns that C<filelist> from the project.
You can also use negative numbers to count from the end.
Returns C<undef> if the specified C<filelist> does not exist.

=cut

        filelist => 'get',

=method map_filelists

Given a code reference, transforms every C<filelist> element into a new
array.

=cut

        map_filelists => 'map',

=method filter_filelists

Given a code reference, returns an array with every C<filelist> element
for which that code returns C<true>.

=cut

        filter_filelists => 'grep',

=method find_filelist

Given a code reference, returns the first C<filelist> for which the code
returns C<true>.

=cut

        find_filelist => 'first',

=method num_filelists

Returns a count of all C<filelist>s in the project.

=cut

        num_filelists => 'count',
    },
);

=attr paths

Hash of
L<XML::Ant::BuildFile::Resource::Path|XML::Ant::BuildFile::Resource::Path>s
from the build file.  The keys are the path C<id>s.

=cut

has paths => (
    auto_deref  => 1,
    isa         => 'HashRef[XML::Ant::BuildFile::Resource::Path]',
    traits      => [qw(XPathObjectMap Hash)],
    xpath_query => '//classpath[@id]|//path[@id]',
    xpath_key   => './@id',

=method path

Given a list of one or more C<id> strings, returns a list of
L<XML::Ant::BuildFile::Resource::Path|XML::Ant::BuildFile::Resource::Path>s
for C<< <classpath/> >>s and C<< <path/> >>s in the project.

=cut

    handles => { path => 'get', path_pairs => 'kv' },
);

=attr targets

Hash of L<XML::Ant::BuildFile::Target|XML::Ant::BuildFile::Target>s
from the build file.  The keys are the target names.

=cut

has targets => (
    auto_deref  => 1,
    isa         => 'HashRef[XML::Ant::BuildFile::Target]',
    traits      => [qw(XPathObjectMap Hash)],
    xpath_query => '/project/target[@name]',
    xpath_key   => './@name',
    handles     => {

=method target

Given a list of target names, return the corresponding
L<XML::Ant::BuildFile::Target|XML::Ant::BuildFile::Target>
objects.  In scalar context return only the last target specified.

=cut

        target => 'get',

=method all_targets

Returns a list of all targets as
L<XML::Ant::BuildFile::Target|XML::Ant::BuildFile::Target>
objects.

=cut

        all_targets => 'values',

=method target_names

Returns a list of the target names from the build file.

=cut

        target_names => 'keys',

=method has_target

Given a target name, returns true or false if the target exists.

=cut

        has_target => 'exists',

=method num_targets

Returns a count of the number of targets in the build file.

=cut

        num_targets => 'count',
    },
);

no Moose::Util::TypeConstraints;
no Moose;

1;
