package t::lib::Test::CentralMoments;

use strict;
use warnings;
use parent 'Test::Builder::Module';

use Test::More;
use Statistics::CentralMoments::Online;

our @EXPORT = (
  @Test::More::EXPORT,
  qw(
      is_around
  )
);

sub import {
    unshift @INC, 't/lib';

    strict->import;
    warnings->import;
    feature->import(':5.12');

    goto &Test::Builder::Module::import;
}

sub is_around {
    my ($got, $expected, $epsilon, $desc) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $delta = abs($got - $expected);
    if ($delta < $epsilon) {
        ok(1, $desc);
    } else {
        ok(0, $desc);
        diag(sprintf "         got: %f", $got);
        diag(sprintf "    expected: %f", $expected);
        diag(sprintf "       delta: %g > %g", $delta, $epsilon);
    }
}

1;
