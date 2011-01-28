#!perl

use Test::More;
use English '-no_match_vars';

eval { use Test::Perl::Critic };
plan skip_all => 'Test::Perl::Critic required to criticize code'
    if $EVAL_ERROR;

all_critic_ok('lib/GSI/Schema/Connection', 'lib/GSI/Content', 'lib/SVN');
