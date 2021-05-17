use Modern::Perl;
use Data::Dot;
use Data::Dumper;
use Test::Simple tests => 4;

$|=1;

# VARS
my %test_hash;
my @test_array;
my $key;
my $expected;
my $result;
my $get_value;

# TEST 1
# Testing one dimensional hash.
$key = 'key1';
$expected = 'value1';
%test_hash = ();

$result = data_set(\%test_hash, $key, $expected);

if ($result) {
    $get_value = $test_hash{$key};

    ok($get_value eq $expected,
        sprintf('Returns wrong value: %s, expected: %s',
            $get_value,
            $expected,
    ));
} else {
    ok($result, 'Returns wrong value: false, expected: true');
}

# TEST 2
# Testing one dimensional array.
$key = '1';
$expected = 'value1';
@test_array = ();

$result = data_set(\@test_array, $key, $expected);

if ($result) {
    $get_value = $test_array[$key];

    ok($get_value eq $expected,
        sprintf('Returns wrong value: %s, expected: %s',
            $get_value,
            $expected,
    ));
} else {
    ok($result, 'Returns wrong value: false, expected: true');
}

# TEST 3
# Testing undef key.
$key = 'key1';
$expected = 'value1';
%test_hash = ();

$result = data_set(\%test_hash, undef, $expected);

ok(!$result, 'Returns wrong value: true, expected: false');

# TEST 4
# Testing zero length key.
$key = '';
$expected = 'value1';
%test_hash = ();

$result = data_set(\%test_hash, $key, $expected);

ok(!$result, 'Returns wrong value: true, expected: false');

# TEST 4
# Testing undef value.
$key = 'key1';
$expected = undef;
%test_hash = ();

$result = data_set(\%test_hash, $key, $expected);

ok(!$result, 'Returns wrong value: true, expected: false');
