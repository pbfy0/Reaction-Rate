#!/usr/bin/perl
use Text::CSV::Simple;
#use Encode;
use Statistics::LineFit;
use Getopt::Long;
#use Data::Dumper;
#use Storable;
use List::Util qw(sum);
use Scalar::Util qw(looks_like_number);
use strict;
use warnings;
$| = 1;
my $ffn = "";
my ($b, $s, $e) = ("","","");
GetOptions("file=s" => \$ffn, "begin|b=i" => \$b, "spacing|s=i" => \$s, "end|e=i" => \$e);

if($b eq "" || $s eq "" || $e eq ""){print "enter begining spacing and end\n"; exit 1}
my @ns = ();
my $j;
if($s == 0){$s = 1}
for($j = $b; $j <= $e; $j += $s){
	push @ns, $j;
}
die "No filename" if($ffn eq "");
my $fh1;
open $fh1, "<$ffn";
my @fn = <$fh1>;
#print ",", join(",", @fn), "\n";
chomp(@fn);
#print ",", join(",", @fn), "\n";
sub cellsf{
my $parser = Text::CSV::Simple->new;
my @cells = $parser->read_file($_[0]);
my $rv = $cells[15]->[1];
my $l = scalar(@cells);
@cells = @cells[27..$l];
my @nc = ();
#@ns = (400);
#sub transpose{
foreach(@cells){
	my $i = 0;
	foreach(@$_){
		unless(defined $nc[$i]){$nc[$i] = []}
		push @{$nc[$i]}, $_;
		$i++;
	}
}
push @nc, $rv;
#return @[@nc, $rv];
return @nc;
}
my @nc = ();
sub doto{
	my @rns = @_;
	my @oa = ();
	my $i = 0;
	my ($s, $e) = ($rns[0], $rns[-1]);
	my @ms = @{$nc[3]}[$s..$e];
	my @ts = @{$nc[1]}[$s..$e];
	my $lf = Statistics::LineFit->new();
#	print $nc[0]->[$s], " ",  $nc[3]->[$s], " ", $nc[1]->[$s], " $s\n";
#	print $nc[0]->[$e], " ",  $nc[3]->[$e], " ", $nc[1]->[$e], " $e\n";
	$lf->setData(\@ts, \@ms);
	my @r = $lf->coefficients();
	return $r[1];
}
sub cash{
#	my @rns = @_;
#	return average(@{$nc[3]}[$_[0]..$_[-1]]);
	
}
sub cmoist{
	my $sm = $nc[3]->[0];
	return $sm - average(@{$nc[3]}[$_[0]..$_[-1]]);
}
my %out = ();
print ",", join(",", @fn), "\n";
my @column = ("Mass", "% Ash", "% Moisture", @ns); #15, 1
my ($tminash, $tmaxash, $tminmoist, $tmaxmoist) = (640, 700, 98, 102);
my ($timminash, $timmaxash, $timminmoist, $timmaxmoist) = (60, 107, 10, 40);
foreach my $cfn(@fn){
#print "$cfn | ";
@nc = cellsf($cfn);
my $mass = pop @nc;
#my $mass = $nc[1]->[15];
#my $l = scalar(@tmpa);
#@nc = @tmpa[27..$l];
my $k = 3;
foreach(@ns){
	my @avg = ();
	my $i = 0;
	my $f = 0;
	foreach my $c (@{$nc[0]}){
		unless(looks_like_number($c)){
			$i++;
			next;
		}
		if($c > $_-2 && $c < $_+2){
			$f = 1;
			push @avg, $i;
		}elsif($f == 1){
			last;
		}
		$i++;
	}


#	print "$_: ", doto(@avg), "\n" unless(@avg == 0);
	my $d = doto(@avg);
	$column[$k] .= ",$d";

	$k++;
}
my $i = 0;
my $fv = "";
my @ash = ();
my @moist = ();
#my ($a, $m) = (0, 0);
foreach my $c (@{$nc[0]}){
	my $tim = $nc[1]->[$i];
	#print "$tim ";
	unless(looks_like_number($c) && looks_like_number($tim)){
		$i++;
		next;
	}
	$fv = $i unless($fv);
#	print "Here ";
#	my $tim = $nc[1]->[$i];
	print STDERR "$c $tim ",   $nc[3]->[$i], " $i\n";
	if($c > $tminash && $c < $tmaxash && $tim > $timminash && $tim < $timmaxash){
#		$a = 1;
		push @ash, $nc[3]->[$i];
	}
	if($c > $tminmoist && $c < $tmaxmoist && $tim > $timminmoist && $tim < $timmaxmoist){
#                       $m = 1;
                       push @moist, $nc[3]->[$i];
        }
	$i++;
}
my $a = average(@ash);
my $m = $nc[3]->[$fv] - average(@moist);
#my $mass = $nc[1]->[15];
$column[0] .= ",$mass";
$column[1] .= ",$a";
$column[2] .= ",$m";
@ash = @moist = ();
}
print join("\n", @column), "\n";
sub average{
	my @it = @_;
	return sum(@it) / scalar(@it);
}
