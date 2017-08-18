package XML::Ant::BuildFile::Task;

# ABSTRACT: Role for Ant build file tasks

=head1 DESCRIPTION

This is a role shared by tasks in an
L<XML::Ant::BuildFile::Project|XML::Ant::BuildFile::Project>.

=head1 SYNOPSIS

    package XML::Ant::BuildFile::Task::Foo;
    use Moose;
    with 'XML::Ant::BuildFile::Task';

    after BUILD => sub {
        my $self = shift;
        print "I'm a ", $self->task_name, "\n";
    };

    1;

=cut

use utf8;
use Modern::Perl '2010';    ## no critic (Modules::ProhibitUseQuotedVersion)

# VERSION
use strict;
use English '-no_match_vars';
use Moose::Role;
use MooseX::Has::Sugar;
use MooseX::Types::Moose 'Str';
use namespace::autoclean;
with 'XML::Ant::BuildFile::Role::InProject';

=attr task_name

Name of the task's XML node.

=cut

has task_name => ( ro, lazy,
    isa      => Str,
    init_arg => undef,
    default  => sub { $_[0]->node->nodeName },
);

no Moose::Role;

1;
