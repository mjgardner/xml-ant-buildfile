package XML::Ant::BuildFile::Element::Arg;

# ABSTRACT: Argument element for a task in an Ant build file

use utf8;
use Modern::Perl '2010';    ## no critic (Modules::ProhibitUseQuotedVersion)

# VERSION
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef Maybe Str);
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use XML::Ant::Properties;
use namespace::autoclean;
with 'XML::Rabbit::Node';

for my $attr (qw(value file path pathref line prefix suffix)) {
    has "_$attr" => ( ro,
        isa         => Str,
        traits      => ['XPathValue'],
        xpath_query => "./\@$attr",
    );
}

has _args => ( ro, lazy,
    builder => '_build__args',
    isa     => ArrayRef [ Maybe [Str] ],
    traits  => ['Array'],
    handles => { args => 'elements' },
);

sub _build__args
{    ## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
    my $self = shift;
    return [ $self->_value ] if $self->_value;
    return [ split / \s /, $self->_line ] if $self->_line;
    {
        ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
        return [
            XML::Ant::Properties->apply(
                '${toString:' . $self->_pathref . '}',
            ),
            ]
            if $self->_pathref;
    }
    return [];
}

no Moose;

1;

__END__

=head1 SYNOPSIS

    package My::Ant::Task;
    use Moose;
    with 'XML::Ant::BuildFile::Task';

    has arg_objects => (
        isa         => 'ArrayRef[XML::Ant::BuildFile::Element::Arg]',
        traits      => ['XPathObjectList'],
        xpath_query => './arg',
    );

    sub all_args {
        my $self = shift;
        return map {$_->args} @{ $self->arg_objects };
    }

=head1 DESCRIPTION

This is an incomplete class to represent C<< <arg/> >> elements in a
L<build file project|XML::Ant::BuildFile::Project>.

=method args

Returns a list of arguments contained in the element.  Currently
handles C<< <arg/> >> elements with the following attributes:

=over

=item value

=item line

=item pathref

=back
