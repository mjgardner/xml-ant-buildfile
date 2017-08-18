package XML::Ant::Properties;

# ABSTRACT: Singleton class for Ant properties

use strict;
use English '-no_match_vars';
use MooseX::Singleton 0.26;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(HashRef Maybe Str);
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything, RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use namespace::autoclean;

has _properties => ( rw,
    isa => HashRef [ Maybe [Str] ],
    init_arg => undef,
    traits   => ['Hash'],
    default  => sub { {} },
    handles  => {
        map { ($_) x 2 }
            qw(count get set delete exists defined keys values clear kv),
    },
);

around set => sub {
    my ( $orig, $self ) = splice @_, 0, 2;
    my %element  = @_;
    my %property = %{ $self->_properties };
    while ( my ( $key, $value ) = each %element ) {
        $property{$key} = $self->apply($value);
    }
    $self->_properties( \%property );
    return $self->$orig(%element);
};

sub apply {
    my $self = shift;
    my $source = shift or return;

    my %property = %{ $self->_properties };
    while ( $source =~ / \$ [{] [\w:.]+ [}] / ) {
        my $old_source = $source;
        while ( my ( $property, $value ) = each %property ) {
            $source =~ s/ \$ [{] $property [}] /$value/g;
        }
        last if $old_source eq $source;
    }
    return $source;
}

1;

__END__

=head1 SYNOPSIS

    use XML::Ant::Properties;
    XML::Ant::Properties->set(foo => 'fooprop', bar => 'barprop');
    my $fooprop = XML::Ant::Properties->apply('${foo}');

=head1 DESCRIPTION

This is a singleton class for storing and applying properties while processing
an Ant build file.  When properties are set their values are also subject to
repeated Ant-style C<${name}> expansion.  You can also perform expansion with
the L<apply|/apply> method.

=method count

=method get

=method set

=method delete

=method exists

=method defined

=method keys

=method values

=method clear

=method kv

=method apply

Takes a string and applies property substitution to it.
