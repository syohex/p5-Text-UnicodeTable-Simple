#!/usr/bin/env perl
use strict;
use warnings;

use lib qw(../lib);

use utf8;
use Text::UnicodeTable::Simple;

binmode STDOUT, ":utf8";

my $t = Text::UnicodeTable::Simple->new;

$t->setCols('Id','Name','Price');
$t->addRow(1,'りんご',24.4);
$t->addRow(2,'パイナップル',21.2);
$t->addRowLine();
$t->addRow(3,'パッションフルーツ',12.3);
$t->addRowLine();
$t->addRow('','Total',57.9);
print $t->draw;

my $no_border_t = Text::UnicodeTable::Simple->new(border => 0);

$no_border_t->setCols('Id','Name','Price');
$no_border_t->addRow(1,'りんご',24.4);
$no_border_t->addRow(2,'パイナップル',21.2);
$no_border_t->addRow(3,'パッションフルーツ',12.3);
$no_border_t->addRow('','Total',57.9);
print $no_border_t->draw;
