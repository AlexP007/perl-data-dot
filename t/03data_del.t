use strict;
use warnings;

use Data::Dot 'data_del';
use Test::Simple tests => 4;

$|=1;

# VARS
my %test_hash;
my @test_array;
my $test_object;
my $expected;
my $result;

# TEST 1
# Testing one dimensional hash.
$expected = 'value1';
%test_hash = (
    key => $expected,
);

$result = data_del(\%test_hash, 'key');

ok($result eq $expected,
    sprintf('Returns wrong value: %s, expected: %s',
        $result,
        $expected,
));

# TEST 2
# Testing one dimensional array.
$expected = 'three';
@test_array = ('one', 'two', $expected, 'four');

$result = data_del(\@test_array, 2);

ok($result eq $expected,
    sprintf('Returns wrong value: %s, expected: %s',
        $result,
        $expected,
));

# TEST 3
# Testing object.
$expected = 'value2';
$test_object = bless {key => $expected}, 'MyClass';

$result = data_del($test_object, 'key');

ok($result eq $expected,
    sprintf('Returns wrong value: %s, expected: %s',
        $result,
        $expected,
));

# TEST 4
# Testing array of hashes.
$expected = 'value2';
@test_array = ('one', 'two', {key1 => 'value1', key2 => $expected}, 'four');

$result = data_del(\@test_array, '2.key2');

ok($result eq $expected,
    sprintf('Returns wrong value: %s, expected: %s',
        $result,
        $expected,
));
