# Copyright (c) 2021 by Alexander Panteleev. This module is free
# software; you can redistribute it and/or modify it under the same
# terms as Perl itself.

package Data::Dot;
# Manipulate data structures with dot notation.
# Works with complex structures like:
# array/hashes/multidimensional arrays, array of hashes, etc.

use Modern::Perl;
use Exporter 'import';
use Scalar::Util 'reftype';

use constant {
    LIMIT => 512,
};

our $VERSION = '1.0.0';
our @EXPORT = qw(data_get data_set);
our @EXPORT_OK = qw(data_get data_set);

# Sub data_get.
# Expects first param to be reference to data struct.
# Second param to be key string. Maximum nested members limit is 512.
# Third optional param is default value. If it's not set it will be undef.
# If key is not found in the struct default will be returned.
sub data_get(+$;$) {
    # Initial.
    my ($data, $key, $default) = @_;

    unless (ref $data || length $key == 0) {
        return $default;
    }

    # Var for intermidiate data in complex structs. Initial value is passed $data.
    # Also last value will be stored here. It's our target.
    my $interim_or_result = $data;
    # Flat array of keys.
    my @keys = split(/\./, $key);
    # Limiting.
    limit(\@keys, LIMIT);

    for my $key (@keys) {
        $interim_or_result = get($interim_or_result, $key);

        return $default unless defined $interim_or_result;
    }

    return $interim_or_result;
}

sub get {
    my ($data, $key) = @_;

    my $type = reftype $data;

    if ($type eq 'HASH') {
        return $data->{$key};
    }

    if ($type eq 'ARRAY') {
        return $data->[$key];
    }

    return undef;

}

sub limit {
    my ($array, $limit) = @_;

    if (scalar @$array > $limit) {
        @$array = @$array[0 .. --$limit];
    }
}

1;
