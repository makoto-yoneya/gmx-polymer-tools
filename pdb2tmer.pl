#!/usr/bin/perl

#    pdb2tmer.pl	M.Yoneya   23.04.2020 

use Getopt::Long;

my $n_term_id = 1;
my $c_term_id = 0;
my $HELP = undef;

GetOptions(
	'n_term_id=i' => \$n_term_id,
	'c_term_id=i' => \$c_term_id,
	'help' => \$HELP
);

if( $HELP ) {
  print "pdb2tmer.pl\n";
  print "Convert a simple pdb file to a trimer pdb file for pdb2gmx.\n";
  print "\n";
  print "usage: ./pdb2tmer.pl [--n_term_id index-for-N-terminal-atom] [--c_term_id index-for-C-terminal-atom] [--help] < input.pdb > output.pdb\n";
  print "\n";
  print "example: ./pdb2tmer.pl --n_term_id 8 --c_term_id 23 < input.pdb >output.pdb\n";
  print "\n";
  exit(0);
}

$natoms = 0;

while ( <> ) {
	$line = $_; 
	chomp $_;
	if ( $_ =~ m/^\s+(.*)/ ) {
		$_ = $1;
	}

	@_ = split (/\s+/, $_);

	if ( $_[0] eq "ATOM" ) {
		$natoms++;
	}
}

if ( $n_term_id < 1 || $n_term_id > $natoms ) {
	die "c_term_id ".$n_term_id." is incorrect\n";
}
else {
	$first = $n_term_id;
}
if ( $c_term_id == 0 ) {
	$c_term_id = $natoms;
}
if ( $c_term_id < 1 || $c_term_id > $natoms ) {
	die "c_term_id ".$c_term_id." is incorrect\n";
}
else {
	$last = $c_term_id;
}
if ( $first == $last ) {
	die "two term_id.s are the same\n";
}

#print "$first, $last\n";

$air = int (($natoms - 2) / 3);

#print "$natoms, $air\n";

if ( ($natoms - 2) != ($air * 3) ) {
	die "No of atoms ".$natoms." not compatible with simple trimer\n";
}

seek(STDIN,0,0);

$na = 0;
$nr = 1;
$nair = 0;

while ( <> ) {
	$line = $_; 
	chomp $_;
	if ( $_ =~ m/^\s+(.*)/ ) {
		$_ = $1;
	}

	@_ = split (/\s+/, $_);

	if ( $_[0] eq "ATOM" && $_[1] != $first && $_[1] != $last ) {
		$na++;
		if ( $nair >= $air ) {
			$nair = 1;
			$nr++;
		} else {
			$nair++;  
		}
#		print "$na, $nr, $nair\n";
		if ( $nr == 1 ) {
			$aname[$nair] = $_[2];
			printf "%-6s%5d %-4s %-4s %4d    %8s%8s%8s\n", $_[0], $na, $_[2], "n".$_[3], $nr, $_[5], $_[6], $_[7];
		}
		elsif ( $nr == 2 ) {
			printf "%-6s%5d %-4s %-3s  %4d    %8s%8s%8s\n", $_[0], $na, $aname[$nair], $_[3], $nr, $_[5], $_[6], $_[7];
		}
		elsif ( $nr == 3 ) {
			printf "%-6s%5d %-4s %-4s %4d    %8s%8s%8s\n", $_[0], $na, $aname[$nair], "c".$_[3], $nr, $_[5], $_[6], $_[7];
		}
		elsif ( $nr > 3 ) {
			die "Residue no. exceeds trimer\n";
		}
	}
}

#for ( $i = 1; $i <= $air; $i++ ) { 
#	print "$aname[$i]\n";
#}
