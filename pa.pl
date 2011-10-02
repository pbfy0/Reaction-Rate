#!/usr/bin/perl
use Spreadsheet::XLSX;
use Data::Dumper;
my $sprsht = Spreadsheet::XLSX->new($ARGV[0]);
my @cells = @{$sprsht->{Worksheet}->[0]->{Cells}};

my @nc = ();
foreach(@cells){
        my $i = 0;
        foreach(@$_){
                unless(defined $nc[$i]){$nc[$i] = []}
                push @{$nc[$i]}, $_;
                $i++;
        }
}
print Dumper \@nc, "\n";

