package XML::Ant::BuildFile::Task::Java;

# ABSTRACT: Java task node in an Ant build file

use Carp;
use English '-no_match_vars';
use Modern::Perl;
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef Str);
use MooseX::Types::Path::Class 'File';
use Path::Class;
use namespace::autoclean;
with 'XML::Ant::BuildFile::Task';

=attr classname

A string representing the Java class that's executed.

=cut

my %xpath_attr = (
    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    classname  => './@classname',
    _jar       => './@jar',
    _args_attr => './@args',
);

while ( my ( $attr, $xpath ) = each %xpath_attr ) {
    has $attr => ( ro,
        isa         => Str,
        traits      => ['XPathValue'],
        xpath_query => $xpath,
    );
}

=attr jar

A L<Path::Class::File|Path::Class::File> for the jar file being executed.

=cut

has jar => ( ro, lazy,
    isa => File,
    default =>
        sub { file( $ARG[0]->project->apply_properties( $ARG[0]->_jar ) ) },
);

=method args

Returns a list of all arguments passed to the Java class.

=cut

has _args => ( ro,
    isa         => 'ArrayRef[XML::Ant::BuildFile::Element::Arg]',
    traits      => [qw(XPathObjectList Array)],
    xpath_query => './arg',
    handles     => { args => [ map => sub { $ARG->args } ] },
);

__PACKAGE__->meta->make_immutable();
1;

__END__

=head1 SYNOPSIS

    use XML::Ant::BuildFile::Project;
    my $project = XML::Ant::BuildFile::Project->new( file => 'build.xml' );
    my @foo_java = $project->target('foo')->tasks('java');
    for my $java (@foo_java) {
        print $java->classname || "$java->jar";
        print "\n";
    }

=head1 DESCRIPTION

This is an incomplete class for
L<Ant Java task|http://ant.apache.org/manual/Tasks/java.html>s in a
L<build file project|XML::Ant::BuildFile::Project>.
