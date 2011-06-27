package Text::UnicodeTable::Simple;

use 5.008_001;
use strict;
use warnings;

our $VERSION = '0.01';

use Carp ();
use Scalar::Util qw(looks_like_number);
use Unicode::EastAsianWidth;

use constant ALIGN_LEFT  => 1;
use constant ALIGN_RIGHT => 2;

# alias for Text::ASCIITable
*setCols    = \&set_header;
*addRow     = \&add_row;
*addRowLine = \&add_row_line;

sub new {
    my $class = shift;

    bless {
        header => [],
        rows   => [],
    }, $class;
}

sub set_header {
    my $self = shift;
    my @headers = _check_argument(@_);

    if (scalar @headers == 0) {
        Carp::croak("Error: Input array has no element");
    }

    $self->{width} = scalar @headers;
    $self->{header} = [ $self->_divide_multiline(\@headers) ];

    return $self;
}

sub _divide_multiline {
    my ($self, $elements_ref) = @_;

    my @each_lines;
    my $longest = -1;
    for my $element (@{$elements_ref}) {
        my @divided = $element ne '' ? (split "\n", $element) : ('');
        push @each_lines, [ @divided ];

        $longest = scalar(@divided) if $longest < scalar(@divided);
    }

    _adjust_cols(\@each_lines, $longest);

    my @rows;
    my @alignments;
    for my $i (0..($longest-1)) {
        my @cells;
        for my $j (0..($self->{width}-1)) {
            $alignments[$j] ||= _decide_alignment($each_lines[$j]->[$i]);
            push @cells, Text::UnicodeTable::Simple::Cell->new(
                text      => $each_lines[$j]->[$i],
                alignment => $alignments[$j],
            );
        }

        push @rows, [ @cells ];
    }

    return @rows;
}

sub _decide_alignment {
    return looks_like_number($_[0]) ? ALIGN_RIGHT : ALIGN_LEFT;
}

sub _adjust_cols {
    my ($cols_ref, $longest) = @_;

    for my $cols (@{$cols_ref}) {
        my $spaces = $longest - scalar(@{$cols});
        push @{$cols}, '' for 1..$spaces;
    }
}

sub add_row {
    my $self = shift;
    my @rows = _check_argument(@_);

    $self->_check_set_header;

    if ($self->{width} < scalar @rows) {
        Carp::croak("Error: Too many elements")
    }

    push @rows, '' for 1..($self->{width} - scalar @rows);

    push @{$self->{rows}}, $self->_divide_multiline(\@rows);

    return $self;
}

sub _check_set_header {
    my $self = shift;

    unless (exists $self->{width}) {
        Carp::croak("Error: you should call 'set_header' method previously");
    }
}

sub _check_argument {
    my @args = @_;

    my @ret;
    if (ref($args[0]) eq "ARRAY") {
        if (scalar @args == 1) {
            @ret = @{$args[0]}
        } else {
            Carp::croak("Error: Multiple ArrayRef arguments");
        }
    } else {
        @ret = @_;
    }

    # replace 'undef' with 0 length string ''
    return map { defined $_ ? $_ : '' } @ret;
}

sub add_row_line {
    my $self = shift;

    $self->_check_set_header;

    my $line = bless [], 'Text::UnicodeTable::Simple::Line';
    push @{$self->{rows}}, $line;

    return $self;
}

sub draw {
    my $self = shift;
    my $str;

    $self->_check_set_header;

    $self->_set_column_length();
    $self->_set_separater();

    # header
    if (scalar $self->{header} != 0) {
        $str .= $self->{separater};
        $str .= $self->_generate_row_string($_) for @{$self->{header}};
        $str .= $self->{separater};
    }

    # body
    for my $row (@{$self->{rows}}) {
        if (ref($row) eq 'ARRAY') {
            $str .= $self->_generate_row_string($row);
        } elsif ( ref($row) eq 'Text::UnicodeTable::Simple::Line') {
            $str .= $self->{separater};
        }
    }

    if (scalar @{$self->{rows}} != 0) {
        unless (ref $self->{rows}->[-1] eq 'Text::UnicodeTable::Simple::Line') {
            $str .= $self->{separater};
        }
    }

    return $str;
}

sub _generate_row_string {
    my ($self, $row_ref) = @_;

    my $str = "|";
    my $index = 0;
    for my $row_elm (@{$row_ref}) {
        $str .= _format($row_elm, $self->_get_column_length($index));
        $str .= '|';
        $index++;
    }
    $str .= "\n";

    return $str;
}

sub _format {
    my ($cell, $width) = @_;

    my $str = $cell->text;
    $str = " $str ";
    my $len = _str_width($str);

    my $retval;
    if ($cell->alignment == ALIGN_RIGHT) {
        $retval = (' ' x ($width - $len)) . $str;
    } else {
        $retval = $str . (' ' x ($width - $len));
    }

    return $retval;
}

sub _set_separater {
    my $self = shift;

    my $each_row_width = $self->{column_length};
    my $str = '+';
    for my $width (@{$each_row_width}) {
        $str .= ('-' x $width);
        $str .= '+';
    }

    $self->{separater} = "$str\n";
}

sub _get_column_length {
    my ($self, $index) = @_;
    return $self->{column_length}->[$index];
}

sub _set_column_length {
    my $self = shift;

    my @cols_length = $self->_column_length($self->{header});
    my @rows_length = $self->_column_length($self->{rows});

    # add space before and after string
    my @max = map { $_ + 2 } _select_max(\@cols_length, \@rows_length);

    $self->{column_length} = \@max;
}

sub _column_length {
    my ($self, $matrix_ref) = @_;

    my $width  = $self->{width};
    my $height = scalar @{$matrix_ref};

    my @each_cols_length;
    for (my $i = 0; $i < $width; $i++) {
        my $max = -1;
        for (my $j = 0; $j < $height; $j++) {
            next unless ref $matrix_ref->[$j] eq 'ARRAY';

            my $cell = $matrix_ref->[$j]->[$i];
            my $len = _str_width($cell->text);
            $max = $len if $len > $max;
        }

        $each_cols_length[$i] = $max;
    }

    return @each_cols_length;
}

sub _select_max {
    my ($a, $b) = @_;

    my ($a_length, $b_length) = map { scalar @{$_} } ($a, $b);
    if ( $a_length != $b_length) {
        Carp::croak("Error: compare different length arrays");
    }

    my @max;
    for my $i (0..($a_length - 1)) {
        push @max, $a->[$i] >= $b->[$i] ? $a->[$i] : $b->[$i];
    }

    return @max;
}

sub _str_width {
    my $str = shift;

    my $ret = 0;
    while ($str =~ /(?:(\p{InFullwidth}+)|(\p{InHalfwidth}+))/go) {
        $ret += ($1 ? length($1) * 2 : length($2));
    }

    return $ret;
}

# utility class
{
    package # hide from pause
        Text::UnicodeTable::Simple::Cell;

    sub new {
        my ($class, %args) = @_;
        bless {
            text      => $args{text},
            alignment => $args{alignment},
        }, $class;
    }

    sub text {
        $_[0]->{text};
    }

    sub alignment {
        $_[0]->{alignment};
    }
}

1;

__END__

=encoding utf-8

=for stopwords

=head1 NAME

Text::UnicodeTable::Simple - Create a formatted table using characters.

=head1 SYNOPSIS

  use Text::UnicodeTable::Simple;

=head1 DESCRIPTION

Text::UnicodeTable::Simple generate character table.
This module can deal with B<Full Width Font>.

L<Text::ASCIITable> is a nice module. But it cannot deal with Full width fonts,
for example Japanese Hiragana, kanji, Hangle, Chinese.

=head1 INTERFACE

=head2 Methods

=head3 new()

Creates and returns a new table instance.

=head3 set_header() [alias: addCols ]

Set the headers for the table. (compare with <th> in HTML).
Input strings should be String, not octet stream.

=head3 add_row(@collist | \@collist) [alias: addRow ]

Add one row to the table.
Input strings should be String, not octet stream.

=head3 add_row_line() [alias: addRowLine ]

Add a line after the current row.

=head3 draw()

Return a string of this table.

=head1 AUTHOR

Syohei YOSHIDA E<lt>syohex@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2011- Syohei YOSHIDA

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Text::ASCIITable>

L<Text::SimpleTable>

L<Text::Table>

=cut
