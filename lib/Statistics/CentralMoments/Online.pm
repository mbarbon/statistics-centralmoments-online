package Statistics::CentralMoments::Online;
# ABSTRACT: online computation of central moments

use strict;
use warnings;

sub new {
    my ($class) = @_;
    my $self = bless {
        count => 0,
        mean  => 0,
        m2    => 0,
        m3    => 0,
        m4    => 0,
    }, $class;

    return $self;
}

sub add_data {
    my ($self, $data) = @_;
    my ($n, $mean, $m2, $m3, $m4) = @{$self}{qw(count mean m2 m3 m4)};

    # http://en.wikipedia.org/wiki/Algorithms_for_calculating_variance
    # uses Terriberry's formulas
    for my $x (@$data) {
        my $delta = $x - $mean;
        my $delta_n = $delta / ($n + 1);
        my $delta_n_sq = $delta_n * $delta_n;
        my $delta_sq_n_n1 = $delta * $delta_n * $n;

        ++$n;
        $mean += $delta_n;
        $m4 += $delta_sq_n_n1 * $delta_n_sq * ($n * $n - 3 * $n + 3) + 6 * $delta_n_sq * $m2 - 4 * $delta_n * $m3;
        $m3 += $delta_sq_n_n1 * $delta_n * ($n - 2) - 3 * $delta_n * $m2;
        $m2 += $delta_sq_n_n1;
    }

    @{$self}{qw(count mean m2 m3 m4)} = ($n, $mean, $m2, $m3, $m4);
}

sub get_moments { [@{$_[0]}{qw(count mean m2 m3 m4)}] }
sub get_count { $_[0]->{count} }
sub get_mean { $_[0]->{mean} }

sub get_variance {
    $_[0]->{count} >= 2 ? $_[0]->{m2} / ($_[0]->{count} - 1) : 0
}

sub get_skewness {
    sqrt($_[0]->{count}) * $_[0]->{m3} * $_[0]->{m2} ** 1.5;
}

sub get_kurtosis {
    $_[0]->{count} * $_[0]->{m4} / ($_[0]->{m2} * $_[0]->{m2}) - 3;
}

sub merge {
    my ($self, $other) = @_;
    my ($n_a, $mean_a, $m2_a, $m3_a, $m4_a) = @{$self->get_moments};
    my ($n_b, $mean_b, $m2_b, $m3_b, $m4_b) = @{$other->get_moments};

    my $delta = $mean_b - $mean_a;
    my $n = $n_a + $n_b;
    my $delta_sq = $delta * $delta;
    my $mean = ($n_a * $mean_a + $n_b * $mean_b) / $n;

    my $n_a_b = $n_a * $n_b;
    my $n_a_sq = $n_a * $n_a;
    my $n_b_sq = $n_b * $n_b;
    my $n_sq = $n * $n;
    my $m2 = $m2_a + $m2_b + $delta_sq * ($n_a_b / $n);
    my $m3 = $m3_a + $m3_b +
        $delta_sq * $delta * (($n_a_b * ($n_a - $n_b)) / $n_sq) +
        3 * $delta * (($n_a * $m2_b - $n_b * $m2_a) / $n);
    my $m4 = $m4_a + $m4_b +
        $delta_sq * $delta_sq * (($n_a_b * ($n_a_sq - $n_a_b + $n_b_sq) / ($n_sq * $n))) +
        6 * $delta_sq * (($n_a_sq * $m2_b + $n_b_sq * $m2_a) / $n_sq) +
        4 * $delta * (($n_a * $m3_b - $n_b * $m3_a) / $n);

    @{$self}{qw(count mean m2 m3 m4)} = ($n, $mean, $m2, $m3, $m4);
}

1;

__END__

=head1 SYNOPSIS

    my $cm = Statistics::CentralMoments::Online->new;

    $cm->add_data(\@data);
    my $mean = $cm->get_mean;
    my ($count, $mean, $m2, $m3, $m4) = @{$cm->get_moments};

    $cm->merge($other_cm);

=head1 DESCRIPTION

Computes the statistical central moments for a set of values, using a
single-pass algorithm.

It uses Timothy Terriberry algorithm, as described in
L<http://en.wikipedia.org/wiki/Algorithms_for_calculating_variance>.

=head1 METHODS

=head2 add_data

    $cm->add_data(\@data);

Adds more data points to the distribution.

=head2 get_moments

   my $moments = $cm->get_moments;
   my ($count, $mean, $m2, $m3, $m4) = @$moments;

Returns the count, (estimated) mean and 2nd, 3rd and 4th moments of
the data seen so far.

=head2 get_mean

    my $mean = $cm->get_mean;

Returns the (estimated) mean of the distribution.

=head2 get_variance

    my $variance = $cm->get_variance;

Returns the (estimated) variance of the distribution.

=head2 get_skewness

    my $skewness = $cm->get_skewness;

Returns the (estimated) skewness of the distribution.

=head2 get_kurtosis

    my $kurtosis = $cm->get_kurtosis;

Returns the (estimated) excess kurtosis of the distribution.

=head2 merge

    $cm->merge($other_cm);

Merge C<$other_cm> into C<$cm>. It does not alter C<$other_cm>.

=cut
