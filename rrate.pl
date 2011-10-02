#!/usr/bin/perl
use Spreadsheet::XLSX;
use Encode;
use Getopt::Long;
use Data::Dumper;
$| = 1;
my $fn = "";
GetOptions("file=s" => \$fn);
my $cv = find_encoding("windows-1251");
die "No filename" if($fn eq "");
my $sprsht = Spreadsheet::XLSX->new($fn);#, $cv);
print "Here\n";
#if (!defined $sprsht){
#	die $sprsht->error(), ".\n";
#}
my $sheet = $sprsht->{Worksheet}->[0];
#print $sheet->{Cells}[0][0]->{Val};
my $cells = $sheet->{Cells};
my @vals = (125, 150, 175, 200, 225);
sub doto{
	my $rn = shift;
	print $cells->[1]->[$rn+1], $cells->[1]->[$rn], $cells->[3]->[$rn+1] , $cells->[3]->[$rn];
#	return -($cells->[1]->[$rn+1] - $cells->[1]->[$rn]) / -($cells->[3]->[$rn+1] - $cells->[3]->[$rn]);
	return  0;
}
my $i = 0;
my @out = ();
my @recells = ();
#@cells = ([1,2],[1,2]);
foreach(@$cells){
	my $j = 0;	
	foreach(@$_){
		unless(defined $recells[$j]){$recells[$j] = []}
		push @{$recells[$j]}, $_->{Val};
		$j++;
	}
}
#print Dumper \@recells;exit;
my @cells = @recells;
#print $cells[0];
#print Dumper \@cells;
print scalar(@{$cells[0]});
foreach(@{$cells[0]}){
#	print Dumper $_;
#	exit;
	my $c = $_;#->{Val};
#	print "$c:";
	foreach(@vals){
		if($c > $_-2 && $c < $_+2){
			print "In Range";
			my $v = doto($i);
			push @out, $v;
		}
	}
	$i++;
}
print join("\n", @out), "\n";
