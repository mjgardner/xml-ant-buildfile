package XML::Ant::BuildFile::Task::Copy;

# ABSTRACT: copy task node in an Ant build file

use utf8;
use Modern::Perl '2010';    ## no critic (Modules::ProhibitUseQuotedVersion)

# VERSION
use English '-no_match_vars';
use Moose;
use MooseX::Types::Moose 'Str';
use MooseX::Has::Sugar;
use MooseX::Types::Path::Class 'File';
use Path::Class;
use XML::Ant::Properties;
use namespace::autoclean;
extends 'XML::Ant::BuildFile::ResourceContainer';
with 'XML::Ant::BuildFile::Task';

for my $attr (qw(dir file)) {
    has "_to_$attr" => ( ro,
        isa         => Str,
        traits      => ['XPathValue'],
        xpath_query => "./\@to$attr",
    );

    has "to_$attr" => ( ro, lazy,
        isa     => "Path::Class::\u$attr",
        default => sub {
            my $method  = "_to_$attr";
            my $applied = XML::Ant::Properties->apply( $_[0]->$method );
            ## no critic (ProhibitStringyEval, RequireCheckingReturnValueOfEval)
            return eval "Path::Class::$attr('$applied')";
        },
    );
}

no Moose;

1;

__END__

=head1 SYNOPSIS

    package My::Ant;
    use Moose;
    with 'XML::Rabbit::Node';

    has paths => (
        isa         => 'ArrayRef[XML::Ant::BuildFile::Task::Copy]',
        traits      => 'XPathObjectList',
        xpath_query => './/copy',
    );

=head1 DESCRIPTION

This is a L<Moose|Moose> type class meant for use with
L<XML::Rabbit|XML::Rabbit> when processing C<< <copy/> >> tasks in an Ant
build file.

=attr to_file

The file to copy to as a L<Path::Class::File|Path::Class::File> object.

=attr to_dir

The directory to copy a set of
L<XML::Ant::BuildFile::Resource|XML::Ant::BuildFile::Resource>s to as a
L<Path::Class::Dir|Path::Class::Dir> object.
