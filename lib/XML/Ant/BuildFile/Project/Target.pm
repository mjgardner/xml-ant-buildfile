package XML::Ant::BuildFile::Project::Target;

# ABSTRACT: target node within an Ant build file

use Moose;
use MooseX::Types::Moose 'Str';
use namespace::autoclean;
with 'XML::Rabbit::Node' => { -version => '0.0.4' };

=attr name

Name of the target.

=cut

has name => (
    isa    => Str,
    traits => ['XPathValue'],
    xpath_query => './@name',   ## no critic (RequireInterpolationOfMetachars)
);

__PACKAGE__->meta->make_immutable();
1;

__END__

=head1 SYNOPSIS

    use XML::Ant::BuildFile::Project;

    my $project = XML::Ant::BuildFile::Project->new( file => 'build.xml' );
    for my $target ( values %{$project->targets} ) {
        print 'got target: ', $target->name, "\n";
    }

=head1 DESCRIPTION

See L<XML::Ant::BuildFile::Project|XML::Ant::BuildFile::Project> for a complete
description.
