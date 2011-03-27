package XML::Ant::BuildFile::Element::Arg;

use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef Maybe Str);
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use namespace::autoclean;
with 'XML::Rabbit::Node';

for my $attr (qw(value file path pathref line prefix suffix)) {
    has "_$attr" => ( ro,
        isa         => Str,
        traits      => ['XPathValue'],
        xpath_query => "./\@$attr",
    );
}

=method args

Returns a list of arguments contained in the element.  Currently
handles C<< <arg/> >> elements with the following attributes:

=over

=item value

=item line

=back

=cut

has _args => ( ro, lazy_build,
    isa => ArrayRef [ Maybe [Str] ],
    traits  => ['Array'],
    handles => { args => 'elements' },
);

sub _build__args
{    ## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
    my $self = shift;
    return [ $self->_value ] if defined $self->_value;
    return [ split / \s /, $self->_line ] if defined $self->_line;
    return [];
}

__PACKAGE__->meta->make_immutable();
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
