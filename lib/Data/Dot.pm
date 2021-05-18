package Data::Dot;

use Modern::Perl;
use Exporter 'import';
use Scalar::Util 'reftype';

our $VERSION = '1.0.0';
our @EXPORT = qw(data_get data_set);
our @EXPORT_OK = qw(data_get data_set);

sub data_get(+$;$) {
    my ($data, $key, $default) = @_;

    return $default unless validate_data_and_key($data, $key);

    return get_by_composite_key($data, $key, $default);
}

# Expects first param to be reference to data struct.
# Second param to be key string.
# Third param is value.
# If key is not defined or is 0 length - false returns.
# Set value without autovivication.
sub data_set(+$$) {
    my ($data, $key, $value) = @_;

    return 0 unless validate_data_and_key($data, $key);

    return set_by_composite_key($data, $key, $value);
}

sub validate_data_and_key {
    my ($data, $key) = @_;

    if (ref $data
    && defined $key
    && length $key) {
        return 1;
    }

    return 0;
}

sub get_by_composite_key {
    my ($data, $key, $default) = @_;
    # Var for intermidiate data in complex structs. Initial value is passed $data.
    # Also last value will be stored here. It's our target.
    my $interim_or_result = $data;
    # Flat array of keys.
    my @keys = split(/\./, $key);

    for my $key (@keys) {
        $interim_or_result = get_by_single_key($interim_or_result, $key);

        return $default unless defined $interim_or_result;
    }

    return $interim_or_result;
}

sub get_by_single_key {
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

sub set_by_composite_key {
    my ($data, $key, $value) = @_;
    # Var for intermidiate data in complex structs. Initial value is passed $data.
    my $interim_or_result = $data;
    # Flat array of keys.
    my @keys = split(/\./, $key);

    for my $i (0 .. $#keys) {
        $key = $keys[$i];

        if ($i == $#keys) {
            return set_by_single_key($interim_or_result, $key, $value);
        } else {
            $interim_or_result = get_by_single_key($interim_or_result, $key);
        }

        return 0 unless defined $interim_or_result;

    }

    return 0;
}

sub set_by_single_key {
    my ($data, $key, $value) = @_;

    my $type = reftype $data;

    if ($type eq 'HASH') {
        $data->{$key} = $value;
        return 1;
    }

    if ($type eq 'ARRAY') {
        $data->[$key] = $value;
        return 1;
    }

    return 0;
}

1;

__END__

# ABSTRACT: Manipulate data structures with dot notation.

=pod

=encoding UTF-8

=head1 NAME

    Data::Dot - Manipulate data I<structures> with I<dot notation>.

=head1 SYNOPSIS

    use Data::Dot;

    # Getting value by key.
    my %hash = (first_key => [{}, {second_key => 'value1'} ]);
    my $value1 = data_get(\%hash, 'first_key.1.second_key'); # value1
    my @array = ({}, {first_key => [ {second_key => 'value2'} ] });
    my $value2 = data_get(\@array, '1.first_key.0.second_key'); # value2

    # Getting undef value if the key is not set.
    my $undef_value = data_get(\%hash, 'third_key.2.second_key'); # undef

    # Getting default value if the key is not set.
    my $default = 'dafault';
    my $default_value = data_get(\%hash, 'third_key.2.second_key', $default); # $default

    # Setting value.
    my $set_succes = data_set(\@array, '1.first_key.2', {third_key => 'value3'}); #true
    my $set_failed = data_set(\@array, '1.third_key.2', {fours_key => 'value3'}); # false

=head1 DESCRIPTION

    Manipulate data I<structures> with I<dot notation>.
    Works with complex I<structures> like:  array/hashes/multidimensional arrays, array of hashes, etc.

    sub data_get to fetch data from I<structures>.
    sub data_set to set values.

    The main advantage of this approach, that you could generate keys dynamically on the fly
    simply contatinating strings via dot ".".

=head1 TERMS

=over 4

=item I<Structs> or I<structures> is arrays, hashes or objects.

=item I<Dot notation> is a string containing the keys of nested structures separated by a dot: ".". Looks like "key.1.name", where "1" could be an array index or hash/object key.

=back

=head2 data_get

    Fetches data from complex I<structures> using a I<dot notation> key.

    Expects first param to be reference to data I<structs>.
    Second param to be I<dot notation> key string.
    Third optional param is default value. If it's not set it will be undef.
    
    If key is not found in the I<struct> or is zero length or not defined default value will be returned.

=head1 VERSION

    version 1.0.0

=head1 SOURCE CODE REPOSITORY

    https://github.com/AlexP007/perl-data-dot - fork or add pr.

=head1 TODO

=over 4

=item * delete sub

=item * immutable subs like data_get_i & data_set_i

=back

=head1 AUTHOR

    Alexander Panteleev <alex.panteleev@protonmail.com>

=head1 COPYRIGHT AND LICENSE

    This software is copyright (c) 2021 by Alexander Panteleev.

    This is free software; you can redistribute it and/or modify it under
    the same terms as the Perl 5 programming language system itself.

=cut
