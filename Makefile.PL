use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Text::Lorem::More',
    AUTHOR              => 'Robert Krimen <robertkrimen@gmail.com>',
    VERSION_FROM        => 'lib/Text/Lorem/More.pm',
    ABSTRACT_FROM       => 'lib/Text/Lorem/More.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Text-Lorem-More-*' },
);