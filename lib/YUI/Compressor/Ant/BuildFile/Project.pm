package YUI::Compressor::Ant::BuildFile::Project;

use English '-no_match_vars';
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef HashRef Str);
use namespace::autoclean;
with 'XML::Rabbit::RootNode';

has name => (
    isa         => Str,
    traits      => ['XPathValue'],
    xpath_query => '/project/@name',
);

has _properties => (
    isa => HashRef [Str],
    traits      => ['XPathValueMap'],
    xpath_query => '//property[@name and @value]',
    xpath_key   => './@name',
    xpath_value => './@value',
    default     => sub { {} },
);

has properties => ( ro, isa => HashRef[Str], default => sub { {} } );

around properties => sub {
    my ($orig, $self) = @ARG;
    return { %{$self->_properties}, %{$self->$orig() } };
};

has filelists => (
    isa    => 'HashRef[YUI::Compressor::Ant::BuildFile::Project::FileList]',
    traits => ['XPathObjectMap'],
    xpath_query => '/project/filelist',
    xpath_key   => './@id',
);

no Moose;
__PACKAGE__->meta->make_immutable();
1;
