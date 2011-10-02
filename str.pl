#!/usr/bin/perl
use Spreadsheet::XLSX;
use Storable;

my $sprsht = Spreadsheet::XLSX->new($ARGV[0]);
my @cells = @{$sprsht->{Worksheet}->[0]->{Cells}};
#print Dumper \@cells;
store \@cells,  "$ARGV[1]";exit;
