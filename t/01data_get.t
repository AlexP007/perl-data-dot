use Modern::Perl 1.20200211;
use Data::Dot 1.0.0;
use Test::Simple 1.302183 tests => 12;

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

# TEST 8
# Testing undef key.
$expected = 'default';
%test_hash = (
    key => 'value1',
);

$result = data_get(\%test_hash, undef, $expected);

ok($result eq $expected,
    sprintf('Returns wrong value: %s, expected: %s',
        $result,
        $expected,
));

# TEST 9
# Testing zero length key.
$expected = 'default';
%test_hash = (
    key => 'value1',
);

$result = data_get(\%test_hash, '', $expected);

ok($result eq $expected,
    sprintf('Returns wrong value: %s, expected: %s',
        $result,
        $expected,
));

# TEST 10
# Testing object attribute.
$expected = 'value2';
%test_hash = (
    key1 => [{}, {key2 =>$expected}],
);
$test_object = bless {hash => \%test_hash}, 'MyClass';

$result = data_get($test_object, 'hash.key1.1.key2');

ok($result eq $expected,
    sprintf('Returns wrong value: %s, expected: %s',
        $result,
        $expected,
));

# TEST 11
# Testing object getters.
package MyClass;

sub get_hash {
    my $self = shift;
    return $self->{hash};
}

package main;

$expected = 'value2';
%test_hash = (
    key1 => [{}, {key2 =>$expected}],
);

$test_object = bless {hash => \%test_hash}, 'MyClass';

$result = data_get($test_object, 'get_hash.key1.1.key2');

ok($result eq $expected,
    sprintf('Returns wrong value: %s, expected: %s',
        $result,
        $expected,
));

# TEST 12
# Testing object accessors via Class::XSAccessor.
package MyClassAccessor;
use Class::XSAccessor accessors => {name => 'name'};

package main;

$expected = 'test_name';
$test_object = bless {name => $expected}, 'MyClassAccessor';

$result = data_get($test_object, 'name');

ok($result eq $expected,
    sprintf('Returns wrong value: %s, expected: %s',
        $result,
        $expected,
));
