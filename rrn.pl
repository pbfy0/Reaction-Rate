#!/usr/bin/perl
#use Spreadsheet::XLSX;
use Text::CSV::Simple;
use Encode;
use Statistics::LineFit;
use Getopt::Long;
use Data::Dumper;
use Storable;
use List::Util qw(sum);
use strict;
use warnings;
$| = 1;
my $fn = "";
my ($b, $s, $e) = ("","","");
GetOptions("file=s" => \$fn, "begin|b=i" => \$b, "spacing|s=i" => \$s, "end|e=i" => \$e);
if($b eq "" || $s eq "" || $e eq ""){print "enter begining spacing and end\n"; exit 1}
my @ns = ();
my $j;
if($s == 0){$s = 1}
#print "$b,$s,$e\n";
#($b,$s,$e) = (300,25,600);
for($j = $b; $j <= $e; $j += $s){
	push @ns, $j;
}
#print join(",", @ns); exit;
my $cv = find_encoding("windows-1251");
die "No filename" if($fn eq "");
my $parser = Text::CSV::Simple->new;
my @cells = $parser->read_file($fn);
#print Dumper \@cells;
#my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
#                 or die "Cannot use CSV: ".Text::CSV->error_diag ();
#open my $fh, "<:encoding(utf8)", "$fn" or die "$fn: $!";
#my @cells = ();
#while( my $r = $csv->getline($fh) ){
#	push @cells, $csv->parse($r);
#}
#my $sprsht = Spreadsheet::XLSX->new($fn);
#my @cells = @{$sprsht->{Worksheet}->[0]->{Cells}};
#print Dumper \@cells;
#store \@cells,  "cells.str";exit;
#my @cells = @{retrieve("cells.str")};
my @nc = ();
#my @cells = ([1,2,3],[1,2,3]);
@ns = (400);
foreach(@cells){
	my $i = 0;
	foreach(@$_){
		unless(defined $nc[$i]){$nc[$i] = []}
		push @{$nc[$i]}, $_;
		$i++;
	}
}
sub doto{
	my @rns = @_;
#	my @dms = ();
#	my @dts = ();
	my @oa = ();
	my $i = 0;
	my ($s, $e) = ($rns[0], $rns[-1]);
	my @ms = @{$nc[3]}[$s..$e];
	my @ts = @{$nc[1]}[$s..$e];
#	my @tm = @{$nc[3]};
#	my @tt = @{$nc[1]};
#	my @ms = @tm[$s..$e];
#	my @ts = @tt[$s..$e];
	my $lf = Statistics::LineFit->new();
	print $nc[0]->[$s], " ",  $nc[3]->[$s], " ", $nc[1]->[$s], " $s\n";
	print $nc[0]->[$e], " ",  $nc[3]->[$e], " ", $nc[1]->[$e], " $e\n";
	$lf->setData(\@ts, \@ms);
	my @r = $lf->coefficients();
	return $r[1];
#	foreach(@rns){
#		print "$i,", scalar(@rns), " ";
#		print "$_\n";
#		unless($i >= scalar(@rns)-1){
#			next if($_ == 75);
#			push @oa, -($nc[3]->[$_] - $nc[3]->[$_+1]) / -($nc[1]->[$_] - $nc[1]->[$_+1]);
#			print $nc[3]->[$_]->{Val}, " ", $nc[1]->[$_]->{Val}, " ", -($nc[3]->[$_]->{Val} - $nc[3]->[$_+1]->{Val}) / -($nc[1]->[$_]->{Val} - $nc[1]->[$_+1]->{Val}) , " ", $_,  "\n";
#			print $nc[0]->[$_], " ",  $nc[3]->[$_], " ", $nc[1]->[$_], " $_\n";
#			print -($nc[3]->[$_] - $nc[3]->[$_+1]), "\n";
#		}
#		$i++;
#	}
#	my $dm = average(@dms);#-($nc[1]->[$rn] - $nc[1]->[$rn+1]);
#	my $dt = average(@dts);#-($nc[3]->[$rn] - $nc[3]->[$rn+1]);
#	return $dm / $dt;
	return average(@oa);
}
#print Dumper \@nc;exit;
#print $nc[0]->[1]->{Val};
#my @avg = ();
my %out = ();
#my $i = 0;
foreach(@ns){
	my @avg = ();
	my $i = 0;
	my $f = 0;
	foreach my $c (@{$nc[0]}){
#		$c = $c->{Val};
#		print "$c\n";
		if($c > $_-2 && $c < $_+2){
			$f = 1;
			push @avg, $i;
		}elsif($f == 1){
			push @avg, $i;
			last;
		}
		$i++;
	}
	print "$_: ", doto(@avg), "\n" unless(@avg == 0);
}
#my $scns;
#foreach(@{$nc[0]}){
#	print Dumper $_;
#	exit;
#	my $c = $_->{Val};
#	print "$c:";
#	foreach my $cns(@ns){
#		print "$cns:$c,";
#		if( $c > $cns-2 && $c < $cns+2){
#			print "In Range ";
#			push @avg, $i;
#			$scns = $cns;
#			print scalar(@avg), " ";
#			print "$cns,$c";
#		}elsif(scalar(@avg) > 0){
#			print "Here\n";
#			push @avg, $i;
#			if(!defined($out{$scns})){$out{$scns} = []}
#			$out{$scns} = doto(@avg);
#			print doto(@avg);
#			@avg = ();
#		}else{
#			print "There ", scalar(@avg), "\n";
#		}
#		if($i >= scalar(@{$nc[0]})-1 && scalar(@avg) > 0){
#			push @avg, $i;
#			push @out, doto(@avg);
#		$out{$scns} = doto(@avg);
#			print doto(@avg);
#			@avg = ();
#		}
#	}
#	$i++;
#}
#print join("\n", @out), "\n";
#foreach(keys %out){
#	print "$_: $out{$_}\n";
#}
sub average{
	my @it = @_;
	return sum(@it) / scalar(@it);
}
