package XML::Ant::BuildFile::Resource;

# ABSTRACT: Role for Ant build file resources

use strict;
use English '-no_match_vars';
use Moose::Role;
use MooseX::Has::Sugar;
use MooseX::Types::Moose 'Str';
use namespace::autoclean;
with 'XML::Ant::BuildFile::Role::InProject';

=attr resource_name

Name of the task's XML node.

=cut

has resource_name => ( ro, lazy,
    isa      => Str,
    init_arg => undef,
    default  => sub { $ARG[0]->node->nodeName },
);

1;

__END__

=head1 SYNOPSIS

    package XML::Ant::BuildFile::Resource::Foo;
    use Moose;
    with 'XML::Ant::BuildFile::Resource';

    after BUILD => sub {
        my $self = shift;
        print "I'm a ", $self->resource_name, "\n";
    };

    1;

=head1 DESCRIPTION

This is a role shared by resources in an
L<XML::Ant::BuildFile::Project|XML::Ant::BuildFile::Project>.
