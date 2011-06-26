use strict;
use warnings;

use Test::More;
use Text::UnicodeTable::Simple;

{
    my $t = Text::UnicodeTable::Simple->new();

    can_ok($t, 'add_row');
    can_ok($t, 'addRow'); # alias

    $t->add_row(qw/a b c d/);
    ok($t->{width} == 4, 'set table width');
}

{
    my $t = Text::UnicodeTable::Simple->new();
    $t->add_row([ qw/a b c/ ]);
    ok($t->{width} == 3, 'argument is ArrayRef');
}

{
    my $t = Text::UnicodeTable::Simple->new();

    can_ok($t, 'add_row_line');
    can_ok($t, 'addRowLine'); # alias

    $t->add_row_line;
    isa_ok($t->{rows}->[0], 'Text::UnicodeTable::Simple::Line');
}

{
    my $t = Text::UnicodeTable::Simple->new();

    $t->set_header(qw/aaa bbb ccc/);

    eval {
        $t->add_row(qw/a b c d e/);
    };
    like $@, qr{Too many elements}, 'too long argument';

    eval {
        $t->add_row(['a'], ['b']);
    };
    like $@, qr{Multiple ArrayRef arguments}, 'set multiple ArrayRef';


}

done_testing;
