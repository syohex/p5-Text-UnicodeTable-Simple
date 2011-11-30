use inc::Module::Install;
use Module::Install::AuthorTests;
use Module::Install::Repository;

name 'Text-UnicodeTable-Simple';
all_from 'lib/Text/UnicodeTable/Simple.pm';

requires 'Unicode::EastAsianWidth' => '1.30';
requires 'Term::ANSIColor';

test_requires 'Test::More' => '0.88';

author_tests('xt');
auto_set_repository();
WriteAll;
