use strict;
use warnings;

use Test::More;
use Text::UnicodeTable::Simple;

my $t = Text::UnicodeTable::Simple->new();

my $alignment;
$alignment = Text::UnicodeTable::Simple::_decide_alignment('123');
is($alignment, Text::UnicodeTable::Simple::ALIGN_RIGHT, "number alignment");

$alignment = Text::UnicodeTable::Simple::_decide_alignment('  abc  ');
is($alignment, Text::UnicodeTable::Simple::ALIGN_LEFT, "not number alignment");

done_testing;
