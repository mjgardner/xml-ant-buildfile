package Algorithm::Dependency::Source::Ant::Buildfile::Types;

# ABSTRACT: Type library for Ant build files

use strict;
use English '-no_match_vars';
use MooseX::Types -declare => ['Buildfile'];
## no critic (Subroutines::ProhibitCallsToUndeclaredSubs)
use MooseX::Types::Moose 'Str';
use MooseX::Types::Path::Class 'File';
use XML::LibXML;
use namespace::autoclean;

=for :stopwords Buildfile buildfile

=type Buildfile

An instance of L<XML::LibXML::Node|XML::LibXML::Node> that has at least one
C<< <filelist/> >> element inside a C<< <project/> >> element.

=cut

class_type Buildfile, { class => 'XML::LibXML::Node' },
    where { $ARG->exists('/project/filelist') };

__PACKAGE__->meta->make_immutable();
1;

__END__

=head1 SYNOPSIS

    use Moose;
    use Algorithm::Dependency::Source::Ant::Buildfile::Types 'Buildfile';

    has xml => ( is => 'ro', isa => Buildfile, required => 1 );

    1;

=head1 DESCRIPTION

This is a simple type library for Ant build file dependencies.
