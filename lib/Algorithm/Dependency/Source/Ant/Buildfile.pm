package Algorithm::Dependency::Source::Ant::Buildfile;

# ABSTRACT: track dependencies in Ant build files

use English '-no_match_vars';
use List::Util 'first';
use Moose;
use MooseX::NonMoose;
use Algorithm::Dependency::Item;
use Algorithm::Dependency::Source::Ant::Buildfile::Types 'Buildfile';
use namespace::autoclean;
extends 'Algorithm::Dependency::Source';

has xml => ( is => 'ro', isa => Buildfile, required => 1 );

sub _load_item_list {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self = shift;

    my @items;
    for my $node ( $self->xml->findnodes('/project/filelist') ) {
        my @kids = $node->getChildrenByTagName('file');
        push @items,
            Algorithm::Dependency::Item->new(
            $node->getAttribute('id'),
            map { _child_name( $node, $ARG ) } @kids,
            ),
            map {
            Algorithm::Dependency::Item->new( _child_name( $node, $ARG ) )
            } @kids;
    }
    return \@items;
}

sub _child_name {
    my ( $node, $child ) = @ARG;
    return $node->getAttribute('dir') . q{/} . $child->getAttribute('name');
}

__PACKAGE__->meta->make_immutable();
1;

__END__

=head1 SYNOPSIS

    use Algorithm::Dependency;
    use Algorithm::Dependency::Source::Ant::Buildfile;
    use XML::LibXML;

    my $source = Algorithm::Dependency::Source::Ant::Buildfile->new(
        xml => XML::LibXML->load_xml(file => 'build.xml') );
    my $dependency = Algorithm::Dependency->new(source => $source);

=for :stopwords plugin

=head1 DESCRIPTION

This is a source plugin for L<Algorithm::Dependency|Algorithm::Dependency>
to track dependencies of file lists within L<Ant|http://ant.apache.org/>
build files.
