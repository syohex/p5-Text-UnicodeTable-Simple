use strict;
use warnings;

use Test::More;
use Text::UnicodeTable::Simple;

my $t = Text::UnicodeTable::Simple->new();
ok($t);
isa_ok($t, "Text::UnicodeTable::Simple");

can_ok($t, 'setCols');
$t->setCols('apple', 'orange', 'melon');
is_deeply($t->{cols}, ['apple', 'orange', 'melon']);

$t->setCols(['apple', 'orange', 'melon']);
is_deeply($t->{cols}, ['apple', 'orange', 'melon']);

eval {
    $t->setCols(['apple'], ['orange']);
};
like($@, qr{Multiple ArrayRef arguments});

done_testing;
