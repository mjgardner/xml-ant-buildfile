package XML::Ant::BuildFile::Project;

# ABSTRACT: consume Ant build files

use English '-no_match_vars';
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Has::Sugar::Minimal;
use MooseX::Types::Moose qw(ArrayRef HashRef Str);
use MooseX::Types::Path::Class 'File';
use Path::Class;
use Readonly;
extends 'XML::Ant::BuildFile::ResourceContainer';
with 'XML::Rabbit::RootNode';

=attr file

On top of L<XML::Rabbit|XML::Rabbit>'s normal behavior, this class will also
coerce L<Path::Class::File|Path::Class::File> objects to the strings expected
by L<XML::Rabbit::Role::Document|XML::Rabbit::Role::Document>.

=cut

subtype 'FileStr', as Str;
coerce 'FileStr', from File, via {"$ARG"};
has '+_file' => ( isa => 'FileStr', coerce => 1 );

{
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

=method filelists

Returns an array of all L<filelist|XML::Ant::BuildFile::FileList>s in the
project.

=method filelist

Given an index number returns that C<filelist> from the project.
You can also use negative numbers to count from the end.
Returns C<undef> if the specified C<filelist> does not exist.

=method map_filelists

Given a code reference, transforms every C<filelist> element into a new
array.

=method filter_filelists

Given a code reference, returns an array with every C<filelist> element
for which that code returns C<true>.

=method find_filelist

Given a code reference, returns the first C<filelist> for which the code
returns C<true>.

=method num_filelists

Returns a count of all C<filelist>s in the project.

=cut

    has _filelists => (
        isa         => 'ArrayRef[XML::Ant::BuildFile::Resource::FileList]',
        traits      => [qw(XPathObjectList Array)],
        xpath_query => '//filelist[@id]',
        handles     => {
            filelists        => 'elements',
            filelist         => 'get',
            map_filelists    => 'map',
            filter_filelists => 'grep',
            find_filelist    => 'first',
            num_filelists    => 'count',
        },
    );

=attr paths

Hash of
L<XML::Ant::BuildFile::Element::Path|XML::Ant::BuildFile::Element::Path>s
from the build file.  The keys are the path C<id>s.

=method path

Given a list of one or more C<id> strings, returns a list of
L<XML::Ant::BuildFile::Element::Path|XML::Ant::BuildFile::Element::Path>s
for C<< <classpath/> >>s and C<< <path/> >>s in the project.

=cut

    has paths => (
        auto_deref  => 1,
        isa         => 'HashRef[XML::Ant::BuildFile::Resource::Path]',
        traits      => [qw(XPathObjectMap Hash)],
        xpath_query => '//classpath[@id]|//path[@id]',
        xpath_key   => './@id',
        handles     => { path => 'get', path_pairs => 'kv' },
    );

=attr targets

Hash of L<XML::Ant::BuildFile::Target|XML::Ant::BuildFile::Target>s
from the build file.  The keys are the target names.

=method target

Given a list of target names, return the corresponding
L<XML::Ant::BuildFile::Target|XML::Ant::BuildFile::Target>
objects.  In scalar context return only the last target specified.

=method all_targets

Returns a list of all targets as
L<XML::Ant::BuildFile::Target|XML::Ant::BuildFile::Target>
objects.

=method target_names

Returns a list of the target names from the build file.

=method has_target

Given a target name, returns true or false if the target exists.

=method num_targets

Returns a count of the number of targets in the build file.

=cut

    has targets => (
        auto_deref  => 1,
        isa         => 'HashRef[XML::Ant::BuildFile::Target]',
        traits      => [qw(XPathObjectMap Hash)],
        xpath_query => '/project/target[@name]',
        xpath_key   => './@name',
        handles     => {
            target       => 'get',
            all_targets  => 'values',
            target_names => 'keys',
            has_target   => 'exists',
            num_targets  => 'count',
        },
    );
}

=method BUILD

After construction, the app-wide L<XML::Ant::Properties|XML::Ant::Properties>
singleton stores any C<< <property/> >> name/value pairs set by the build file.
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

    XML::Ant::Properties->set(
        'os.name'          => $OSNAME,
        'basedir'          => file( $self->_file )->dir->stringify(),
        'ant.file'         => $self->_file,
        'ant.project.name' => $self->name,
        %{ $self->_properties },
    );
    return;
}

1;

__END__

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

=head1 DESCRIPTION

This class uses L<XML::Rabbit|XML::Rabbit> to consume Ant build files using
a L<Moose|Moose> object-oriented interface.  It is a work in progress and in no
way a complete implementation of all Ant syntax.
