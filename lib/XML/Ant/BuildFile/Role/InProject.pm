package XML::Ant::BuildFile::Role::InProject;

# ABSTRACT: role for nodes in an Ant project

=head1 DESCRIPTION

This is a role providing common attributes for all child nodes in an
L<XML::Ant::BuildFile::Project|XML::Ant::BuildFile::Project>.

=head1 SYNOPSIS

    package My::Project::Node;
    use Moose;
    with 'XML::Ant::BuildFile::Role::InProject';

    1;

=cut

use utf8;
use Modern::Perl '2010';    ## no critic (Modules::ProhibitUseQuotedVersion)

# VERSION
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

no Moose::Role;

1;
