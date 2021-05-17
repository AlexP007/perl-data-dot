package Data::Dot;
# ABSTRACT: Manipulate data structures with dot notation.

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
    # ARGS.
    my ($data, $key, $default) = @_;

    unless (ref $data
    && defined($key)
    && length $key
    ) {
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

# Sub data_set.
# Expects first param to be reference to data struct.
# Second param to be key string. Maximum nested members limit is 512.
# Third param is value.
# If key is not defined or is 0 length - false returns.
# Set value without autovivication.
sub data_set(+$$) {
    # ARGS.
    my ($data, $key, $value) = @_;

    unless (ref $data
    && defined($key)
    && length $key
    ) {
        return 0;
    }

    # Flat array of keys.
    my @keys = split(/\./, $key);
    my $keys_length = @keys;
    # Limiting.
    if (scalar $keys_length > 512) {
        return 0;
    }

    # Var for intermidiate data in complex structs. Initial value is passed $data.
    my $interim_or_result = $data;

    my $key_counter = 1;

    for my $key (@keys) {
        if ($key_counter == $keys_length) {
            return set($interim_or_result, $key, $value);
        } else {
            $interim_or_result = get($interim_or_result, $key);
        }

        return 0 unless defined $interim_or_result;

        $key_counter++;
    }

    return 0;
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

sub set {
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

sub limit {
    my ($array, $limit) = @_;

    if (scalar @$array > $limit) {
        @$array = @$array[0 .. --$limit];
    }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

    Data::Dot - Manipulate data structures with dot notation.

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

    Manipulate data structures with dot notation.
    Works with complex structures like:  array/hashes/multidimensional arrays, array of hashes, etc.

    sub data_get to fetch data from structures.
    sub data_set to set values.

    Dot notation is like JavaScript or C# but adds an opportunity to Manipulate arrays additionaly.
    Common key in dot notation looks like "key.1.name", where "1" could be an array index or hash/object key.

    The main advantage of this approach, that you could generate keys dynamically on the fly
    simply contatinating strings via dot ".".

    But there is a small limitation of 512 key members seperated by dot's. Usually this is enough.


=head1 VERSION

    version 1.0.0

=head1 SOURCE CODE REPOSITORY

    https://github.com/AlexP007/perl-data-dot - fork or add pr.

=head1 TODO

=over 4

=item * delete sub
=item * auto vivication in data_set

=back

=head1 AUTHOR

    Alexander Panteleev <alex.panteleev@protonmail.com>

=head1 COPYRIGHT AND LICENSE

    This software is copyright (c) 2021 by Alexander Panteleev.

    This is free software; you can redistribute it and/or modify it under
    the same terms as the Perl 5 programming language system itself.

=cut
