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
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use namespace::autoclean;
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

=attr filelists

Array reference of
L<XML::Ant::BuildFile::FileList|XML::Ant::BuildFile::FileList>s.

=cut

    has filelists => (
        isa         => 'ArrayRef[XML::Ant::BuildFile::FileList]',
        traits      => ['XPathObjectList'],
        xpath_query => '//filelist[@id]',
    );

=attr targets

Hash reference of
L<XML::Ant::BuildFile::Target|XML::Ant::BuildFile::Target>s
from the build file.  The keys are the target names.

=method all_targets

Returns a list of all targets as
L<XML::Ant::BuildFile::Target|XML::Ant::BuildFile::Target>
objects.

=method target_names

Returns a list of the target names from the build file.

=method get_target

Given a list of target names, return the corresponding
L<XML::Ant::BuildFile::Target|XML::Ant::BuildFile::Target>
objects.  In scalar context return only the last target specified.

=method has_target

Given a target name, returns true or false if the target exists.

=method num_targets

Returns a count of the number of targets in the build file.

=cut

    has targets => (
        isa         => 'HashRef[XML::Ant::BuildFile::Target]',
        traits      => [qw(XPathObjectMap Hash)],
        xpath_query => '/project/target[@name]',
        xpath_key   => './@name',
        handles     => {
            target_names => 'keys',
            get_target   => 'get',
            has_target   => 'exists',
            num_targets  => 'count',
            all_targets  => 'values',
        },
    );
}

=attr properties

Read-only hash reference to properties set by the build file.  This also
contains the following predefined properties as per the Ant documentation:

=over

=item os.name

=item basedir

=item ant.file

=item ant.project.name

=back

=cut

has properties => ( is => ro, isa => HashRef [Str], default => sub { {} } );

around properties => sub {
    my ( $orig, $self ) = @ARG;
    return {
        'os.name'          => $OSNAME,
        'basedir'          => file( $self->_file )->dir->stringify(),
        'ant.file'         => $self->_file,
        'ant.project.name' => $self->name,
        %{ $self->_properties },
        %{ $self->$orig() },
    };
};

=method apply_properties

Takes a string and applies L<property|/properties> substitution to it.

=cut

sub apply_properties {
    my ( $self, $source ) = @ARG;
    my %properties = %{ $self->properties };

    while ( $source =~ / \$ { [\w.]+ } / ) {
        while ( my ( $property, $value ) = each %properties ) {
            $source =~ s/ \$ {$property} /$value/g;
        }
    }
    return $source;
}

__PACKAGE__->meta->make_immutable();
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
a L<Moose|Moose> object-oriented interface.
