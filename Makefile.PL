use inc::Module::Install;
use Module::Install::AuthorTests;
use Module::Install::ReadmeMarkdownFromPod;

name 'Text-UnicodeTable-Simple';
all_from 'lib/Text/UnicodeTable/Simple.pm';
readme_markdown_from('lib/Text/UnicodeTable/Simple.pm');

author_tests('xt');
auto_set_repository();
WriteAll;
