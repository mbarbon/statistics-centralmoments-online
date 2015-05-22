package Statistics::CentralMoments::Online;
# ABSTRACT: online computation of central moments

use strict;
use warnings;

# VERSION

require XSLoader;
XSLoader::load('Statistics::CentralMoments::Online', $VERSION);

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
