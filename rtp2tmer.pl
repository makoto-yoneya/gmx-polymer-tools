#!/usr/bin/perl

#    rtp2trimer.pl	M.Yoneya   04.22.2020 

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
  print "rtp2tmer.pl\n";
  print "Convert a simple rtp file to a trimer rtp file.\n";
  print "\n";
  print "usage: ./rtp2tmer.pl [--n_term_id index-for-N-terminal-atom] [--c_term_id index-for-C-terminal-atom] [--help] < input.rtp > output.rtp\n";
  print "\n";
  print "example: ./rtp2tmer.pl --n_term_id 8 --c_term_id 23 < input.rtp >output.rtp\n";
  print "\n";
  exit(0);
}

$status = "initial";
$natoms = 0;
$nbonds = 0;

while ( <> ) {
	$line = $_; 
	chomp $_;
	if ( $_ =~ m/^\s+(.*)/ ) {
		$_ = $1;
	}

	@_ = split (/\s+/, $_);

	if ( $_[0] eq "[" and  $_[2] eq "]" ) {
		if ( $status eq "initial" ) {
			$molname = $_[1];
		}
		$status = $_[1];
	} elsif ( $status eq "atoms" ) {
		$natoms++;
	} elsif ( $status eq "bonds" ) {
		$nbonds++;
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
$bir = int (($nbonds - 1) / 3);

#print "$molname\n";
#print "$natoms, $air\n";
#print "$nbonds, $bir\n";

if ( ($natoms - 2) != ($air * 3) ) {
	die "No of atoms ".$natoms." not compatible with simple trimer\n";
}
if ( ($nbonds - 1) != ($bir * 3) ) {
	die "No of bonds ".$nbonds." not compatible with simple trimer\n";
}

open (TEMPFILE, "> temp.rtp");

seek(STDIN,0,0);

$status = "initial";
$na = 0;
$nb = 0;
$nair = 0;

while ( <> ) {
	$line = $_; 
	chomp $_;
	if ( $_ =~ m/^\s+(.*)/ ) {
		$_ = $1;
	}

	@_ = split (/\s+/, $_);

	if ( $_[0] eq "[" and  $_[2] eq "]" ) {
		if ( $status eq "initial" ) {
			print TEMPFILE "[ n".$molname." ]\n";
		} else {
			print TEMPFILE $line;
		}
		$status = $_[1];
	} elsif ( $status eq "atoms" ) {
		if ( $na == ($air + 1) ) {
			print TEMPFILE "[ ".$molname." ]\n";
			print TEMPFILE " [ atoms ]\n";
		} elsif ( $na == ($air * 2  + 1) ) {
			print TEMPFILE "[ c".$molname." ]\n";
			print TEMPFILE " [ atoms ]\n";
		}		
		print TEMPFILE $line;
		$na++;
		if ( $na == $first ) {
			$aname[0] = $_[0];
		}
		elsif ( $na == $last) {
			$aname[3*$air+1] = $_[0];
		}
		else {
			$nair++;  
			$aname[$nair] = $_[0]; 
		}
	} elsif ( $status eq "bonds" ) {
		if ( $nb == ($bir + 1) || $nb == ($bir * 2  + 1) ) {
			print TEMPFILE " [ bonds ]\n";
#			print TEMPFILE "$last_bond[1] $last_bond[0]\n";
		}
		$last_bond[0] = $_[0];
		$last_bond[1] = $_[1];
		print TEMPFILE $line;
		$nb++;
	}
}

close (TEMPFILE);

open (TEMPFILE, "< temp.rtp");

for ( $target = 1; $target <= 3; $target++ ) { 

	$status = "initial";
	$ia = 0;
	$ib = 0;
	$ir = 0;
	$nb = 0;
	
	while ( <TEMPFILE> ) {
		$line = $_; 
		chomp $_;
		if ( $_ =~ m/^\s+(.*)/ ) {
			$_ = $1;
		}
	
		@_ = split (/\s+/, $_);
	
		if ( $_[0] eq "[" and  $_[2] eq "]" ) {
			if ( $_[1] eq "atoms" ) {
				$ia++;
				if ( $ia == $target ) {
					print $line;
				}
			} elsif ( $_[1] eq "bonds" ) {
				$ib++;
				if ( $ib == $target ) {
					print $line;
				}
			} else {
				$ir++;
				if ( $ir == $target ) {
					print $line;
				}
			}
			$status = $_[1];
		} elsif ( $status eq "atoms" ) {
			if ( $ia == $target ) {
				for ( $i = $air+1; $i <= $nair; $i++ ) { 
					if ( $_[0] eq $aname[$i] ) { 
						$j = $i % $air;
						if ( $j == 0 ) {
							$j = $air;
						}
						last;
					}
				}
				if ( $i <= $nair ) { 
					printf "%6s%6s%14s%6s\n", $aname[$j], $_[1], $_[2], $_[3];
				}
				else {
					print $line;
				}
			}		
		} elsif ( $status eq "bonds" ) {
			$nb++;
			if ( $ib == $target ) {
				for ( $i = $air+1; $i <= $nair; $i++ ) { 
					if ( $_[0] eq $aname[$i] ) { 
						$j = $i % $air;
						if ( $j == 0 ) {
							$j = $air;
						}
						last;
					}
				}
				for ( $k = $air+1; $k <= $nair; $k++ ) { 
					if ( $_[1] eq $aname[$k] ) { 
						$l = $k % $air;
						if ( $l == 0 ) {
							$l = $air;
						}
						last;
					}
				}
				if ( $nb == ($bir + 1) || $nb == ($bir * 2  + 1) ) {
					if ( $i <= $nair && $k <= $nair ) { 
						if ( aname2index ($aname[$j]) < aname2index ($aname[$l]) ) {
							printf "%6s%6s\n", "+".$aname[$j], $aname[$l];
						} else {
							printf "%6s%6s\n", $aname[$j], "+".$aname[$l];
						}
					}
					elsif ( $i <= $nair && $k > $nair ) { 
						if ( aname2index ($aname[$j]) < aname2index ($_[1]) ) {
							printf "%6s%6s\n", "+".$aname[$j], $_[1];
						} else {
							printf "%6s%6s\n", $aname[$j], "+".$_[1];
						}
					}
					elsif ( $i > $nair && $k <= $nair ) { 
						if ( aname2index ($_[0]) < aname2index ($aname[$l]) ) {
							printf "%6s%6s\n", "+".$_[0], $aname[$l];
						} else {
							printf "%6s%6s\n", $_[0], "+".$aname[$l];
						}
					}
					else {
						if ( aname2index ($_[0]) < aname2index ($_[1]) ) {
							printf "%6s%6s\n", "+".$_[0], $_[1];
						} else {
							printf "%6s%6s\n", $_[0], "+".$_[1];
						}
					}
				}
				else { 
					if ( $i <= $nair && $k <= $nair ) { 
						printf "%6s%6s\n", $aname[$j], $aname[$l];
					}
					elsif ( $i <= $nair && $k > $nair ) { 
						printf "%6s%6s\n", $aname[$j], $_[1];
					}
					elsif ( $i > $nair && $k <= $nair ) { 
						printf "%6s%6s\n", $_[0], $aname[$l];
					}
					else {
						printf "%6s%6s\n", $_[0], $_[1];
					}
				}
			}
		}
	}

	seek(TEMPFILE,0,0);
}

close (TEMPFILE);

unlink ("temp.rtp");

sub aname2index {
	my $arg = shift;
	for ( $i = 1; $i <= $nair; $i++ ) { 
		if ( $arg eq $aname[$i] ) { 
			last;
		}
	}
	if ( $i <= $nair ) {
		return $i;
	}
	else {
		die "error in aname2index\n";
	}
}
