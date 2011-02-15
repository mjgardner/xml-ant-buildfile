#!perl

use Path::Class;
use Test::More;
use English '-no_match_vars';

eval { use Test::Perl::Critic };
plan skip_all => 'Test::Perl::Critic required to criticize code'
    if $EVAL_ERROR;

Test::Perl::Critic->import(
    -profile => dir(qw(xt author perlcritic.rc))->stringify() );
all_critic_ok( 'lib/GSI/Schema/Connection', 'lib/GSI/Content', 'lib/SVN' );
