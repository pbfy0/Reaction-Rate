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
my %out = ();
print ",", join(",", @fn), "\n";
my @column = ("%ASH", "%MOISTURE", @ns);

foreach my $cfn(@fn){
#print "$cfn | ";
@nc = cellsf($cfn);
my $k = 2;
foreach(@ns){
	my @avg = ();
	my $i = 0;
	my $f = 0;
	foreach my $c (@{$nc[0]}){
		next unless(looks_like_number($c));
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
}
}
print join("\n", @column), "\n";
sub average{
	my @it = @_;
	return sum(@it) / scalar(@it);
}
