use Modern::Perl;
use Data::Dot;
use Data::Dumper;
use Test::Simple tests => 9;

$|=1;

# VARS
my %test_hash;
my @test_array;
my $test_object;
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


# TEST 5
# Testing array of hashes.
$key = '2.key2';
$expected = 'value2';
@test_array = ('one', 'two', {key1 => 'value1'}, 'four');

$result = data_set(\@test_array, $key, $expected);

if ($result) {
    $get_value = $test_array[2]->{key2};

    ok($get_value eq $expected,
        sprintf('Returns wrong value: %s, expected: %s',
            $get_value,
            $expected,
    ));
} else {
    ok($result, 'Returns wrong value: false, expected: true');
}

# TEST 6
# Testing reference pass.
$key = '2.key2';
$expected = 'value2';
@test_array = ('one', 'two', {key1 => 'value1'}, 'four');

$result = data_set(@test_array, $key, $expected);

if ($result) {
    $get_value = $test_array[2]->{key2};

    ok($get_value eq $expected,
        sprintf('Returns wrong value: %s, expected: %s',
            $get_value,
            $expected,
    ));
} else {
    ok($result, 'Returns wrong value: false, expected: true');
}

# TEST 7
# Testing complex struct.
$key = 'key1.1.key2';
$expected = 'value2';
%test_hash = (
    key1 => [{}, {}],
);

$result = data_set(\%test_hash, $key, $expected);

if ($result) {
    $get_value = $test_hash{key1}->[1]{key2};

    ok($get_value eq $expected,
        sprintf('Returns wrong value: %s, expected: %s',
            $get_value,
            $expected,
    ));
} else {
    ok($result, 'Returns wrong value: false, expected: true');
}

# TEST 8
# Testing object key.
$key = 'key';
$expected = 'value';

$test_object = bless {}, 'MyClass';

$result = data_set($test_object, $key, $expected);

if ($result) {
    $get_value = $test_object->{$key};

    ok($get_value eq $expected,
        sprintf('Returns wrong value: %s, expected: %s',
            $get_value,
            $expected,
    ));
} else {
    ok($result, 'Returns wrong value: false, expected: true');
}

# TEST 9
# Testing object setter via Class::XSAccessor.
package MyClassSetter;
use Class::XSAccessor setters => {'set_key' => 'key'};

package main;

$key = 'key';
$expected = 'value';

$test_object = bless {}, 'MyClassSetter';

$result = data_set($test_object, 'set_key', $expected);

if ($result) {
    $get_value = $test_object->{$key};

    ok($get_value eq $expected,
        sprintf('Returns wrong value: %s, expected: %s',
            $get_value,
            $expected,
    ));
} else {
    ok($result, 'Returns wrong value: false, expected: true');
}
