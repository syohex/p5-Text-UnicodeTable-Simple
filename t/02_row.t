use strict;
use warnings;

use Test::More;
use Text::UnicodeTable::Simple;

my $t = Text::UnicodeTable::Simple->new();

can_ok($t, 'addRow');

can_ok($t, 'addRowLine');

done_testing;
