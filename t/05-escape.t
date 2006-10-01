#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use_ok("Text::Lorem::More");
use Text::Lorem::More qw(lorem);

#warn lorem->generate("++");
#warn lorem->parse("++name");
