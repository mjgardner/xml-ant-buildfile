package XML::Ant::BuildFile::Project;

# ABSTRACT: consume Ant build files

use English '-no_match_vars';
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Has::Sugar::Minimal;
use MooseX::Types::Moose qw(ArrayRef HashRef Str);
use MooseX::Types::Path::Class 'File';
use namespace::autoclean;
with 'XML::Rabbit::RootNode';

has properties => ( is => ro, isa => HashRef [Str], default => sub { {} } );

around properties => sub {
    my ( $orig, $self ) = @ARG;
    return { %{ $self->_properties }, %{ $self->$orig() } };
};

=attr file

On top of L<XML::Rabbit|XML::Rabbit>'s normal behavior, this class will also
coerce L<Path::Class::File|Path::Class::File> objects to the strings expected
by L<XML::Rabbit::Role::Document|XML::Rabbit::Role::Document>.

=cut

subtype 'FileStr', as Str;
coerce 'FileStr', from File, via {"$ARG"};
has '+_file' => ( isa => 'FileStr', coerce => 1 );

{    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    has name => (
        isa         => Str,
        traits      => ['XPathValue'],
        xpath_query => '/project/@name',
    );

    has _properties => (
        isa => HashRef [Str],
        traits      => ['XPathValueMap'],
        xpath_query => '//property[@name and @value]',
        xpath_key   => './@name',
        xpath_value => './@value',
        default     => sub { {} },
    );

    has filelists => (
        isa         => 'HashRef[XML::Ant::BuildFile::Project::FileList]',
        traits      => ['XPathObjectMap'],
        xpath_query => '/project/filelist',
        xpath_key   => './@id',
    );

    has targets => (
        isa => ArrayRef [Str],
        traits      => ['XPathValueList'],
        xpath_query => '/project/target/@name',
    );
}

__PACKAGE__->meta->make_immutable();
1;

__END__

=head1 SYNOPSIS

    use XML::Ant::BuildFile::Project;

    my $project = XML::Ant::BuildFile::Project->new( file => 'build.xml' );
    print 'Project name: ', $project->name, "\n";
    print "File lists:\n";
    my %file_lists = %{$project->file_lists};
    while (my ($name, $list_ref) = each %file_lists) {
        print "$name\n";
        print join "\n", @{$list_ref->files};
        print "\n\n";
    }

=head1 DESCRIPTION

This class uses L<XML::Rabbit|XML::Rabbit> to consume Ant build files using
a L<Moose|Moose> object-oriented interface.
