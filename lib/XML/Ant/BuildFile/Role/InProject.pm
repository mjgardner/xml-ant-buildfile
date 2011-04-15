package XML::Ant::BuildFile::Role::InProject;

# ABSTRACT: role for nodes in an Ant project

use strict;
use Moose::Role;
use namespace::autoclean;
with 'XML::Rabbit::Node' => { -version => '0.0.4' };

=attr project

Reference to the L<XML::Ant::BuildFile::Project|XML::Ant::BuildFile::Project>
at the root of the build file.

=cut

has project => (
    isa         => 'XML::Ant::BuildFile::Project',
    traits      => ['XPathObject'],
    xpath_query => q{/},
);

1;

__END__

=head1 SYNOPSIS

    package My::Project::Node;
    use Moose;
    with 'XML::Ant::BuildFile::Role::InProject';

    1;

=head1 DESCRIPTION

This is a role providing common attributes for all child nodes in an
L<XML::Ant::BuildFile::Project|XML::Ant::BuildFile::Project>.
