package XML::Ant::BuildFile::Resource;

# ABSTRACT: Role for Ant build file resources

use strict;
use English '-no_match_vars';
use Moose::Role;
use MooseX::Has::Sugar;
use MooseX::Types::Moose 'Str';
use namespace::autoclean;
with 'XML::Ant::BuildFile::Role::InProject';

=attr as_string

Every role consumer must implement the C<as_string> method.

=cut

requires 'as_string';

=attr resource_name

Name of the task's XML node.

=cut

has resource_name => ( ro, lazy,
    isa      => Str,
    init_arg => undef,
    default  => sub { $ARG[0]->node->nodeName },
);

=attr id

C<id> attribute of this resource.

=cut

{
## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    has id =>
        ( ro, isa => Str, traits => ['XPathValue'], xpath_query => './@id' );
}

=method BUILD

After a resource is constructed, it adds its L<id|/id> and
L<string representation|/as_string> to the
L<XML::Ant::Properties|XML::Ant::Properties> singleton with C<toString:>
prepended to the C<id>.

=cut

sub BUILD {
    my $self = shift;
    if ( $self->id ) {
        XML::Ant::Properties->set(
            'toString:' . $self->id => $self->as_string );
    }
    return;
}

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
