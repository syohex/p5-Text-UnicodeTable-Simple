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

sub new {
    my $class = shift;

    bless {
        cols => [],
        rows => [],
    }, $class;
}

sub setCols {
    my $self = shift;
    my @cols = _check_argument(@_);

    my $width = scalar @cols;

    $self->{width} = $width;
    $self->{cols}  = [ @cols ];
}

sub addRow {
    my $self = shift;
    my @rows = _check_argument(@_);

    if ($self->{width} > scalar @rows) {
        Carp::croak("Too many elements")
    }

    push @rows, undef for 1..($self->{width} - scalar @rows);

    push @{$self->{rows}}, [ @rows ];
}

sub _check_argument {
    my @args = @_;

    my @ret;
    if (ref($args[0]) eq "ARRAY") {
        if (scalar @args == 1) {
            @ret = @{$args[0]}
        } else {
            Carp::croak("Multiple ArrayRef arguments");
        }
    } else {
        @ret = @_;
    }

    return @ret;
}

sub addRowLine {
    my $self = shift;

    my $line = bless [], 'Text::UnicodeTable::Simple::Line';
    push @{$self->{rows}}, $line;
}

sub draw {
    my $self = shift;
    my $str;

    $self->_set_column_length();
    $self->_set_separater();

    # header
    if (scalar $self->{cols} != 0) {
        $str .= $self->{separater};
        $str .= $self->_generate_row_string($_) for @{$self->{cols}};
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

    $str .= $self->{separater};
}

sub _generate_row_string {
    my ($self, $row_ref) = @_;

    my $index = 0;
    my $str;

    $str .= "|";
    for my $row_elm (@{$row_ref}) {
        $str .= _format($row_elm, $self->_get_column_length($index));
        $str .= '|';
        $index++;
    }
    $str .= "\n";

    return $str;
}

sub _format {
    my ($str, $width) = @_;

    $str = " $str ";
    my $len = _str_width($str);
    my $retval;
    if (looks_like_number($_[0])) {
        # 'NUMBER' is right adjusted
        $retval = (' ' x ($width - $len)) . $str;
    } else {
        # Not 'NUMBER' is right adjusted
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

    my $width = $self->{width};
    my $rows  = $self->{rows};

    my $rows_num = scalar @{$rows};

    my @each_cols_length;
    for (my $i = 0; $i < $width; $i++) {
        my $max = _str_width($self->{cols}->[$i]);
        for (my $j = 0; $j < $rows_num; $j++) {
            next unless ref $rows->[$j] eq 'ARRAY';

            my $len = _str_width($rows->[$j]->[$i]);
            $max = $len if $len > $max;
        }

        # add space before and after string
        push @each_cols_length, $max + 2;
    }

    $self->{column_length} = \@each_cols_length;
}

sub _str_width {
    my $str = shift;

    my $ret = 0;
    while ($str =~ /(?:(\p{InFullwidth}+)|(\p{InHalfwidth}+))/go) {
        $ret += ($1 ? length($1) * 2 : length($2));
    }

    return $ret;
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

Text::UnicodeTable::Simple is

L<Text::ASCIITable> is a nice module. But it cannot deal with Full width fonts,
for example Japanese Hiragana, kanji, Hangle, Chinese.

=head1 INTERFACE

=head2 Methods

=head3 new()

=head3 setCols()

=head3 addRow(@collist | \@collist)

Add one row to the table.

=head3 addRowLine()

Add a line after the current row.

=head3 draw()

=head1 AUTHOR

Syohei YOSHIDA E<lt>syohex@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2011- Syohei YOSHIDA

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
