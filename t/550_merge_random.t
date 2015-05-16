#!/usr/bin/env perl

use t::lib::Test::CentralMoments;
use List::Util qw(sum);

my @data = map int(sum(map rand(50), 1 .. 60)), 1 .. 4000;
my @splits = map int(rand(3500)) + 500, 1 .. 10;

my $cm = Statistics::CentralMoments::Online->new;

$cm->add_data(\@data);

my ($count, $mean, $m2, $m3, $m4) = @{$cm->get_moments};

for my $split (@splits) {
    my $cm_a = Statistics::CentralMoments::Online->new;
    my $cm_b = Statistics::CentralMoments::Online->new;

    my @a = @data[0 .. $split - 1];
    my @b = @data[$split .. $#data];

    $cm_a->add_data(\@a);
    $cm_b->add_data(\@b);

    $cm_a->merge($cm_b);

    my ($count_m, $mean_m, $m2_m, $m3_m, $m4_m) = @{$cm_a->get_moments};

    is($count_m, $count, "sample count");
    is_around($mean_m, $mean, 0.0000001, "mean");
    note("\t$count, $mean, $m2, $m3, $m4\n");
    note("$split\t$count_m, $mean_m, $m2_m, $m3_m, $m4_m\n");
    is_relative($m2_m, $m2, 0.00000000000001, "m2");
    is_relative($m3_m, $m3, 0.00000000001, "m3");
    is_relative($m4_m, $m4, 0.00000000000001, "m4");
}

done_testing();
