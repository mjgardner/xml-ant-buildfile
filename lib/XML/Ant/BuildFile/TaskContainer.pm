#
# This file is part of XML-Ant-BuildFile
#
# This software is copyright (c) 2014 by GSI Commerce.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use utf8;
use Modern::Perl;    ## no critic (UselessNoCritic,RequireExplicitPackage)

package XML::Ant::BuildFile::TaskContainer;
$XML::Ant::BuildFile::TaskContainer::VERSION = '0.216';

# ABSTRACT: Container for XML::Ant::BuildFile::Task plugins

use English '-no_match_vars';
use List::Util 1.33 'any';
use Moose;
use Module::Pluggable (
    sub_name    => 'task_plugins',
    search_path => 'XML::Ant::BuildFile::Task',
    require     => 1,
);
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)

sub BUILD {
    my $self = shift;

    ## no critic (ValuesAndExpressions::ProhibitMagicNumbers)
    my %isa_map = map { lc( ( split /::/ => $ARG )[-1] ) => $ARG }
        $self->task_plugins;
    $self->meta->add_attribute(
        _tasks => (
            traits      => [qw(XPathObjectList Array)],
            xpath_query => join( q{|} => map {".//$ARG"} keys %isa_map ),
            isa_map     => \%isa_map,
            handles     => {
                all_tasks    => 'elements',
                task         => 'get',
                filter_tasks => 'grep',
                find_task    => 'first',
                num_tasks    => 'count',
            },
        ),
    );
    return;
}

sub tasks {
    my ( $self, @names ) = @ARG;
    return $self->filter_tasks(
        sub {
            any { $_ eq $ARG->task_name } @names;
        },
    );
}

no Moose;

1;

__END__

=pod

=encoding UTF-8

=for :stopwords Mark Gardner GSI Commerce cpan testmatrix url annocpan anno bugtracker rt
cpants kwalitee diff irc mailto metadata placeholders metacpan

=head1 NAME

XML::Ant::BuildFile::TaskContainer - Container for XML::Ant::BuildFile::Task plugins

=head1 VERSION

version 0.216

=head1 SYNOPSIS

    package XML::Ant::BuildFile::Task::Foo;
    use Moose;
    extends 'XML::Ant::BuildFile::TaskContainer';

=head1 DESCRIPTION

Base class for containers of multiple
L<XML::Ant::BuildFile::Task|XML::Ant::BuildFile::Task> plugins.

=head1 METHODS

=head2 all_tasks

Returns an array of task objects contained in this target.

=head2 task

Given an index number returns that task from the target.

=head2 filter_tasks

Returns all task objects for which the given code reference returns C<true>.

=head2 num_tasks

Returns a count of the number of tasks in this target.

=head2 BUILD

Automatically run after object construction to set up task object support.

=head2 tasks

Given one or more task names, returns a list of task objects.

=head1 SUPPORT

=head2 Perldoc

You can find documentation for this module with the perldoc command.

  perldoc XML::Ant::BuildFile::Project

=head2 Websites

The following websites have more information about this module, and may be of help to you. As always,
in addition to those websites please use your favorite search engine to discover more resources.

=over 4

=item *

MetaCPAN

A modern, open-source CPAN search engine, useful to view POD in HTML format.

L<http://metacpan.org/release/XML-Ant-BuildFile>

=item *

Search CPAN

The default CPAN search engine, useful to view POD in HTML format.

L<http://search.cpan.org/dist/XML-Ant-BuildFile>

=item *

RT: CPAN's Bug Tracker

The RT ( Request Tracker ) website is the default bug/issue tracking system for CPAN.

L<https://rt.cpan.org/Public/Dist/Display.html?Name=XML-Ant-BuildFile>

=item *

AnnoCPAN

The AnnoCPAN is a website that allows community annotations of Perl module documentation.

L<http://annocpan.org/dist/XML-Ant-BuildFile>

=item *

CPAN Ratings

The CPAN Ratings is a website that allows community ratings and reviews of Perl modules.

L<http://cpanratings.perl.org/d/XML-Ant-BuildFile>

=item *

CPAN Forum

The CPAN Forum is a web forum for discussing Perl modules.

L<http://cpanforum.com/dist/XML-Ant-BuildFile>

=item *

CPANTS

The CPANTS is a website that analyzes the Kwalitee ( code metrics ) of a distribution.

L<http://cpants.cpanauthors.org/dist/XML-Ant-BuildFile>

=item *

CPAN Testers

The CPAN Testers is a network of smokers who run automated tests on uploaded CPAN distributions.

L<http://www.cpantesters.org/distro/X/XML-Ant-BuildFile>

=item *

CPAN Testers Matrix

The CPAN Testers Matrix is a website that provides a visual overview of the test results for a distribution on various Perls/platforms.

L<http://matrix.cpantesters.org/?dist=XML-Ant-BuildFile>

=item *

CPAN Testers Dependencies

The CPAN Testers Dependencies is a website that shows a chart of the test results of all dependencies for a distribution.

L<http://deps.cpantesters.org/?module=XML::Ant::BuildFile::Project>

=back

=head2 Bugs / Feature Requests

Please report any bugs or feature requests through the web
interface at L<https://github.com/mjgardner/xml-ant-buildfile/issues>. You will be automatically notified of any
progress on the request by the system.

=head2 Source Code

The code is open to the world, and available for you to hack on. Please feel free to browse it and play
with it, or whatever. If you want to contribute patches, please send me a diff or prod me to pull
from your repository :)

L<https://github.com/mjgardner/xml-ant-buildfile>

  git clone git://github.com/mjgardner/xml-ant-buildfile.git

=head1 AUTHOR

Mark Gardner <mjgardner@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by GSI Commerce.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
