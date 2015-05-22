#!/usr/bin/env perl

use t::lib::Test::CentralMoments;

my $cm = Statistics::CentralMoments::Online->new;

is($cm->get_count, 0);
is_around($cm->get_mean, 0, 1e-6);
is_around($cm->get_variance, 0, 1e-6);

$cm->add_data([5, 6, 7]);
$cm->add_data([8]);
$cm->add_data([8, 7, 6, 7, 8, 9, 2]);
$cm->add_data([3, 4]);

my ($count, $mean, $m2, $m3, $m4) = @{$cm->get_moments};
is($count, 13);
is_around($mean, 6.1538, 0.0001);
is_around($m2 / 13, 4.13018, 0.00001);
is_around($m3 / 13, -5.44834, 0.00001);
is_around($m4 / 13, 40.1503, 0.0001);
is_around($cm->get_variance, 4.4744, 0.0001);

done_testing();
