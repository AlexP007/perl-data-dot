package Data::Dot;

use strict;
use warnings;

use Exporter 'import';
use Scalar::Util 'blessed';

our $VERSION   = '1.00';
our @EXPORT_OK = qw(data_get data_set data_del);

sub data_get {
    my ($data, $key, $default) = @_;

    return $default unless validate($data, $key);

    return get_by_composite_key($data, $key, $default);
}

sub data_set {
    my ($data, $key, $value) = @_;

    return 0 unless validate($data, $key);

    return set_by_composite_key($data, $key, $value);
}

sub data_del {
    my ($data, $key) = @_;

    return undef unless validate($data, $key);

    return del_by_composite_key($data, $key);
}

sub validate {
    my ($data, $key) = @_;

    return validate_data($data) && validate_key($key);
}

sub validate_data {
    my ($data) = @_;

    return ref $data;
}

sub validate_key {
    my ($key) = @_;

    return defined $key && length $key;
}

sub get_by_composite_key {
    my ($data, $key, $default) = @_;

    # Var for intermediate data in complex structs. Initial value is passed $data.
    # Also last value will be stored here. It's our target.
    my $interim_or_result = $data;

    # Flat array of keys.
    my @keys = split_composite_dot_key($key);

    for my $key (@keys) {
        $interim_or_result = get_by_single_key($interim_or_result, $key);

        return $default unless defined $interim_or_result;
    }

    return $interim_or_result;
}

sub set_by_composite_key {
    my ($data, $key, $value) = @_;

    # Var for intermediate data in complex structs. Initial value is passed $data.
    my $interim = $data;

    # Flat array of keys.
    my @keys = split_composite_dot_key($key);

    for my $i (0 .. $#keys) {
        my $key_member = $keys[$i];

        if ($i == $#keys) {
            return set_by_single_key($interim, $key_member, $value);
        }

        else {
            $interim = get_by_single_key($interim, $key_member);
        }

        return 0 unless defined $interim;
    }
}

sub del_by_composite_key {
    my ($data, $key) = @_;

    # Var for intermediate data in complex structs. Initial value is passed $data.
    my $interim = $data;

    # Flat array of keys.
    my @keys = split_composite_dot_key($key);

    for my $i (0 .. $#keys) {
        my $key_member = $keys[$i];

        if ($i == $#keys) {
            return del_by_single_key($interim, $key_member);
        }

        else {
            $interim = get_by_single_key($interim, $key_member);
        }

        return undef unless defined $interim;
    }
}

sub get_by_single_key {
    my ($data, $key) = @_;

    my $type = ref $data;

    if ($type eq 'HASH') {
        return $data->{$key};
    }

    elsif ($type eq 'ARRAY') {
        return $data->[$key];
    }

    # Objects.
    elsif (blessed $data) {
        return object_get($data, $key);
    }

    else {
        return undef;
    }
}

sub set_by_single_key {
    my ($data, $key, $value) = @_;

    my $type = ref $data;

    if ($type eq 'HASH') {
        $data->{$key} = $value;

        return 1;
    }

    elsif ($type eq 'ARRAY') {
        $data->[$key] = $value;

        return 1;
    }

    # Objects.
    elsif (blessed $data) {
        return object_set($data, $key, $value);
    }

    else {
        return 0;
    }
}

sub del_by_single_key {
    my ($data, $key) = @_;

    my $type = ref $data;

    if ($type eq 'HASH') {
        return delete $data->{$key};
    }

    elsif ($type eq 'ARRAY') {
        return delete $data->[$key];
    }

    # Objects.
    elsif (blessed $data) {
        return delete $data->{$key};
    }

    else {
        return undef;
    }
}

sub object_get {
    my ($obj, $key) = @_;

    if ($obj->can($key) ) {
        return $obj->$key;
    }

    return $obj->{$key};

}

sub object_set {
    my ($obj, $key, $value) = @_;

    if ($obj->can($key) ) {
        $obj->$key($value);
    }

    else {
        $obj->{$key} = $value;
    }

    return 1
}

sub split_composite_dot_key {
    my ($key) = @_;

    return split(/\./, $key);
}

1;

__END__

# ABSTRACT: Manipulate data structs with dot notation.

=pod

=encoding UTF-8

=head1 NAME

Data::Dot - Manipulate data I<structs> with I<dot notation>.

=head1 VERSION

version 1.0.0

=head1 SYNOPSIS

    use Data::Dot;

    ## Creating example structs.

    # Hash
    my %author = (name => 'big guy', articles => [{heading => 'first blog'}, {heading => 'second blog'} ]);

    # Array
    my @authors = (\%author);

    # Object.
    my $publisher = bless {authors => \@authors}, 'MyClass'; # it is assumed that accessors will be used

    ## Gettting values.

    # Getting value by key form hash.
    my $second_blog_heading = data_get(\%author, 'articles.1.heading'); # second blog

    # Getting value by key form array.
    my $first_author_first_blog_heading = data_get(\@authors, '0.articles.0.heading'); # first blog

    # Getting undef value if the key is not set.
    my $undef_value = data_get(\%author, 'publisher.address.street'); # undef

    # Getting first author from object.
    my $first_author = data_get($publisher, 'get_authors.1');

    # Default return.
    my $default = 'unknown';

    # Getting default value if the key is not set.
    my $default_value = data_get(\%author, 'publisher.address.street', $default); # unknown

    ## Setting values.

    # Success set.
    my $set_success = data_set(\@authors, '0.articles.2', {heading => 'third blog'}); #true

    # Failed set.
    my $set_failed = data_set(\@authors, '1.articles.2', {heading => 'third blog'}); # false

    # Setting second author to object.
    my $set_object_success = data_set($publisher, 'authors.1', {name => 'another guy'}); #true

=head1 DESCRIPTION

Lightweight module to manipulate data I<structs> with I<dot notation>.
Works with complex I<structures> like: array/hashes/objects/multidimensional arrays/array of hashes, etc.
This module uses a composite I<dot notation> key string like: "person.credentials.name" to work with I<structs>.

The main advantage of this approach, that you could generate keys dynamically on the fly
simply concatenating strings via dot ".".
And it just more readable.

=head2 TERMS

=over 4

=item I<Structs> or I<structures> is arrays, hashes or objects.

=item I<Dot notation> is a string containing the keys of nested structures separated by a dot: ".". Looks like "person.1.name", where "1" could be an array index or hash/object key.

=back

=head2 FUNCTIONS

Unlike other heavy and complex solutions, this module provides two simple functions:

=head3 data_get($data, $key, $default = undef)

Fetches data from complex I<structs> using a I<dot notation> key.

Expects first param to be reference to data I<struct>.
Second param to be I<dot notation> key string.
Third optional param is default value. If it's not set it will be undef.

If I<struct> is an object, first, it will try to call method,
if this does not work, it will refer to the key.

If key is not found in the I<struct> or is zero length or not defined default value will be returned.

=head3 data_set($data, $key, $value)

Sets data in complex I<structs> using a I<dot notation> key.

Expects first param to be reference to data I<struct>.
Second param to be I<dot notation> key string.
Third param is value.
If key is not defined or zero length false will be returned.

If I<struct> is an object, first, it will try to call method,
if this does not work, it will refer to the key.

Set value without autovivication for all key members except last.
this means that if undef is encountered somewhere in the composite key,
except for the last position, then the value will not be initialized.

=head3 data_del($data, $key)

Delete data in complex I<structs> using a I<dot notation> key using
built-in function L<delete|https://perldoc.perl.org/functions/delete>
under the hood.

This function returns undef if something go wrong, aware this.

Could delete key in object, only if this object blessed on hash.
But who create objects from scalar or array anyway?

=head1 TODO

=over 4

=item * data_def() sub - if key is defined

=item * immutable subs like data_get_i & data_set_i

=back

=head1 BUGS

If you find one, please let me know.

=head1 SOURCE CODE REPOSITORY

https://github.com/AlexP007/perl-data-dot - fork or add pr.

=head1 AUTHOR

Alexander Panteleev <alex.panteleev@protonmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2021 by Alexander Panteleev.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
