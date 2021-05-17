use Modern::Perl;
use Data::Dot;
use Data::Dumper;
use Test::Simple tests => 7;

$|=1;

# VARS
my %test_hash;
my @test_array;
my $expected;
my $result;

# TEST 1
# Testing one dimensional hash.
$expected = 'value1';
%test_hash = (
    key => $expected,
);

$result = data_get(\%test_hash, 'key');

ok($result eq $expected,
    sprintf('Returns wrong value: %s, expected: %s',
        $result,
        $expected,
));

# TEST 2
# Testing one dimensional array.
$expected = 'three';
@test_array = ('one', 'two', $expected, 'four');

$result = data_get(\@test_array, 2);

ok($result eq $expected,
    sprintf('Returns wrong value: %s, expected: %s',
        $result,
        $expected,
));

# TEST 3
# Testing default undef value.
$expected = undef;
%test_hash = (
    key => 'value1',
);

$result = data_get(\%test_hash, 'key1');

ok(!defined($result),
    sprintf('Returns wrong value: %s, expected: %s',
        defined $result ? $result : 'undef',
        'undef',
));

# TEST 4
# Testing default passed value.
$expected = 'default';
%test_hash = (
    key => 'value1',
);

$result = data_get(\%test_hash, 'key1', $expected);

ok($result eq $expected,
    sprintf('Returns wrong value: %s, expected: %s',
        $result,
        $expected,
));

# TEST 5
# Testing array of hashes.
$expected = 'value2';
@test_array = ('one', 'two', {key1 => 'value1', key2 => $expected}, 'four');

$result = data_get(\@test_array, '2.key2');

ok($result eq $expected,
    sprintf('Returns wrong value: %s, expected: %s',
        $result,
        $expected,
));

# TEST 6
# Testing reference pass.
$expected = 'value2';
@test_array = ('one', 'two', {key1 => 'value1', key2 => $expected}, 'four');

$result = data_get(@test_array, '2.key2');

ok($result eq $expected,
    sprintf('Returns wrong value: %s, expected: %s',
        $result,
        $expected,
));

# TEST 7
# Testing complex struct.
$expected = 'value2';
%test_hash = (
    key1 => [{}, {key2 =>$expected}],
);

$result = data_get(\%test_hash, 'key1.1.key2');

ok($result eq $expected,
    sprintf('Returns wrong value: %s, expected: %s',
        $result,
        $expected,
));
