#!perl

use Test::More;
use English '-no_match_vars';

eval { use Test::Perl::Critic };
plan skip_all => 'Test::Perl::Critic required to criticize code'
    if $EVAL_ERROR;

my @files = qw(Schema/Configured.pm Types.pm);
plan tests => scalar @files;
critic_ok("lib/GSI/Automerge/$ARG") for @files;
