use strict;
use warnings;

use Test::More;
use Text::UnicodeTable::Simple;

my $t = Text::UnicodeTable::Simple->new();

can_ok($t, 'add_row');
can_ok($t, 'addRow'); # alias

can_ok($t, 'add_row_line');
can_ok($t, 'addRowLine'); # alias

done_testing;
