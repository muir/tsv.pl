#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 28;
use FindBin;
use File::Temp qw(tempdir);
use File::Slurp;

my $data = "$FindBin::Bin/data";
my $tsv = "$FindBin::Bin/../tsv";
my $tempdir = tempdir(CLEANUP => 1);


sub cmd 
{
	open my $csv, "-|", $^X, $tsv, @_ or die "open $^X $tsv @_: $!";
	return <$csv> if wantarray;
	return join('', <$csv>);
}

sub rows
{
	my (@data) = @_;
	my @r;
	for my $r (@data) {
		push(@r, [ map { s/\s+$//; s/^\s+//; $_ } split(/\t/, $r) ])
	}
	return @r;
}

sub asref
{
	my (@x) = @_;
	return \@x;
}

# diag cmd("--show", "$data/gi.tsv");

is_deeply(asref(rows(cmd("--show", "$data/gi.tsv"))), [
	[ 1, 'name' ],
	[ 2, 'rank' ],
	[ 3, 'serial number' ]], 'show');

is_deeply(asref(rows(cmd("-f", "name", "$data/gi.tsv"))), [
	[ 'name' ],
	[ 'GI Joe' ],
	[ 'GI Jane' ]], 'cut name');

is_deeply(asref(rows(cmd("--cut", "rank,serial number", "$data/gi.tsv"))), [
	[ 'rank', 'serial number' ],
	[ 'Private', '2883081' ],
	[ 'Seargent', '28049' ]], 'cut rank & serial');

is_deeply(asref(rows(cmd("--rotate", "$data/gi.tsv"))), [
	[ 'name',		'GI Joe', 	'GI Jane'],
	[ 'rank',		'Private',	'Seargent'],
	[ 'serial number',	'2883081',	'28049']], 'rotate');

write_file("$tempdir/foo", "FOO\tBAR\tBAZ\nfoo\tbar\tbaz\n");

system("$^X $tsv --match $data/gi.tsv < $tempdir/foo > $tempdir/bar");
ok($? >> 8 == 0, "system status");

# diag read_file("$tempdir/bar");

is_deeply(asref(rows(read_file("$tempdir/bar"))), [
	[ 'name',		'FOO', 	'foo'],
	[ 'rank',		'BAR',	'bar'],
	[ 'serial number',	'BAZ',	'baz']], 'match');


is_deeply(asref(rows(cmd("--grep", "name", "Private", "$data/gi.tsv"))), [], "grep, wrong column");

is_deeply(asref(rows(cmd("--grep", "rank", "Private", "$data/gi.tsv"))), [
	[ 'GI Joe', 'Private', '2883081' ]], "grep, right single column");

is_deeply(asref(rows(cmd("--grep", "rank,name", "Private", "$data/gi.tsv"))), [
	[ 'GI Joe', 'Private', '2883081' ]], "grep, right two columns 1");

is_deeply(asref(rows(cmd("--grep", "rank,name", "Joe", "$data/gi.tsv"))), [
	[ 'GI Joe', 'Private', '2883081' ]], "grep, right two columns 2");

is_deeply(asref(rows(cmd("--select", "/Joe/", "$data/gi.tsv"))), [
	[ 'name', 'rank', 'serial number' ],
	[ 'GI Joe', 'Private', '2883081' ]], 'select on $_');

is_deeply(asref(rows(cmd("--select", '$name =~ /Joe/', "$data/gi.tsv"))), [
	[ 'name', 'rank', 'serial number' ],
	[ 'GI Joe', 'Private', '2883081' ]], 'select on $name');

is_deeply(asref(rows(cmd("--select", '$serial_number =~ /81$/', "$data/gi.tsv"))), [
	[ 'name', 'rank', 'serial number' ],
	[ 'GI Joe', 'Private', '2883081' ]], 'select on $serial_number');

is_deeply(asref(rows(cmd("--validate", "$data/missing.tsv"))), [
	[ 'name', 'rank', 'serial number' ],
	[ 'GI Jane', 'Seargent', '28049' ],
	[ 'GI Zod', '', '' ],
	[ 'GI Joeseph', 'Private', '' ] ], 'validate');

is_deeply(asref(rows(cmd("--validate", "--default", "FOO", "$data/missing.tsv"))), [
	[ 'name', 'rank', 'serial number' ],
	[ 'GI Jane', 'Seargent', '28049' ],
	[ 'GI Zod', 'FOO', 'FOO' ],
	[ 'GI Joeseph', 'Private', 'FOO' ] ], 'validate with default');

is_deeply(asref(rows(cmd("--default", "FOO", "$data/missing.tsv"))), [
	[ 'name', 'rank', 'serial number' ],
	[ 'GI Joe', 'Private'  ],
	[ 'GI Jane', 'Seargent', '28049' ],
	[ 'GI Zack' ],
	[ 'GI Zod', 'FOO', 'FOO' ],
	[ 'GI Joeseph', 'Private', 'FOO' ] ], 'default');



# kinda repeat the above tests with --head

is_deeply(asref(rows(cmd("--head", "500", "$data/longer.tsv"))), [
	[ 'name', 'rank', 'serial number' ],
	[ 'GI Joe', 'Private', '2883081'  ],
	[ 'GI Jane', 'Seargent', '28049' ],
	[ 'GI Zack', 'Corporal', '7219' ],
	[ 'GI Jones', 'PFC', '2819' ]], 'head 500');

is_deeply(asref(rows(cmd("--head", "2", "$data/longer.tsv"))), [
	[ 'name', 'rank', 'serial number' ],
	[ 'GI Joe', 'Private', '2883081'  ],
	[ 'GI Jane', 'Seargent', '28049' ]], 'head 2');

is_deeply(asref(rows(cmd("-n", "3", "$data/longer.tsv"))), [
	[ 'name', 'rank', 'serial number' ],
	[ 'GI Joe', 'Private', '2883081'  ],
	[ 'GI Jane', 'Seargent', '28049' ],
	[ 'GI Zack', 'Corporal', '7219' ]], '-n 3');

is_deeply(asref(rows(cmd("-f", "name", "-n", "2", "$data/longer.tsv"))), [
	[ 'name' ],
	[ 'GI Joe' ],
	[ 'GI Jane' ]], 'cut name, -n 2');

is_deeply(asref(rows(cmd("--rotate", "-head", "2", "$data/longer.tsv"))), [
	[ 'name',		'GI Joe', 	'GI Jane'],
	[ 'rank',		'Private',	'Seargent'],
	[ 'serial number',	'2883081',	'28049']], 'rotate with --head 2');

is_deeply(asref(rows(cmd("--grep", "rank", "P", "-n", "500", "$data/longer.tsv"))), [
	[ 'GI Joe', 'Private', '2883081' ],
	[ 'GI Jones', 'PFC', '2819' ]], "grep with --head 500");

is_deeply(asref(rows(cmd("--grep", "rank", "P", "--head", "2", "$data/longer.tsv"))), [
	[ 'GI Joe', 'Private', '2883081' ],
	[ 'GI Jones', 'PFC', '2819' ]], "grep with --head 2");

is_deeply(asref(rows(cmd("--grep", "rank", "P", "--head", "1", "$data/longer.tsv"))), [
	[ 'GI Joe', 'Private', '2883081' ]], "grep with --head 1");

is_deeply(asref(rows(cmd("--select", "/8/", "--head", "1", "$data/longer.tsv"))), [
	[ 'name', 'rank', 'serial number' ],
	[ 'GI Joe', 'Private', '2883081' ]], 'select on $_, with --head 1');

is_deeply(asref(rows(cmd("--select", "/8/", "-n", "2", "$data/longer.tsv"))), [
	[ 'name', 'rank', 'serial number' ],
	[ 'GI Joe', 'Private', '2883081' ],
	[ 'GI Jane', 'Seargent', '28049' ]], 'select on $_, with --head 2');

is_deeply(asref(rows(cmd("--validate", "-n", "2", "$data/missing.tsv"))), [
	[ 'name', 'rank', 'serial number' ],
	[ 'GI Jane', 'Seargent', '28049' ],
	[ 'GI Zod', '', '' ]], 'validate -n 2');

is_deeply(asref(rows(cmd("--default", "FOO", "--head", "4", "$data/missing.tsv"))), [
	[ 'name', 'rank', 'serial number' ],
	[ 'GI Joe', 'Private'  ],
	[ 'GI Jane', 'Seargent', '28049' ],
	[ 'GI Zack' ],
	[ 'GI Zod', 'FOO', 'FOO' ]], 'default with --head 4');

