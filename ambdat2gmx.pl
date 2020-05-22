#!/usr/bin/perl

#    ambdat2gmx.pl	M.Yoneya   30.06.2015 

$cal = 4.184;

$status = "initial";

while ( <> ) {
	$line = $_; 
	chomp $_;
	if ( $_ =~ m/^\s+(.*)/ ) {
		$_ = $1;
	}

	@_ = split (/\s+/, $_);

	if ( $_[0] eq ""  ) {
		if ( $status eq "masstypes" ) {
			$status = "hydrophilic";
			close(ATPFILE);
			open (BONFILE1, "> ffbonded.itp");
			print BONFILE1 "[ bondtypes ]\n";
			print BONFILE1 "; i    j  func       b0          kb\n";
		} elsif ( $status eq "bondtypes" ) {
			$status = "angletypes";
			print BONFILE1 "$line";
			print BONFILE1 "[ angletypes ]\n";
			print BONFILE1 ";  i    j    k  func       th0       cth\n";
		} elsif ( $status eq "angletypes" ) {
			$status = "propertypes";
			close(BONFILE1);
			open (BONFILE2, "> ffbonded2.itp");
			print BONFILE2 "[ dihedraltypes ] ; proper stuff\n";
			print BONFILE2 ";i  j   k  l	 func      phase      kd      pn\n";
		} elsif ( $status eq "propertypes" ) {
			$status = "impropertypes";
			close(BONFILE2);
			open (BONFILE1, ">> ffbonded.itp");
			print BONFILE1 "$line";
			print BONFILE1 "[ dihedraltypes ] ; improper stuff\n";
			print BONFILE1 ";i   j   k   l	   func\n";
		} elsif ( $status eq "impropertypes" ) {
			$status = "gap_after_improper";
			print BONFILE1 "$line";
		} elsif ( $status eq "gap_after_improper" ) {
		} elsif ( $status eq "atomtypes" ) {
			$status = "end";
			close(NONFILE);
			open (DOCFILE, ">> forcefield.doc");
			print DOCFILE "$line";
		}
	} elsif ( $_[0] eq "MOD4" and $_[1] eq "RE" ) {
		$status = "atomtypes";
		close(BONFILE1);
		open (NONFILE, "> ffnonbonded.itp");
		print NONFILE "[ atomtypes ]\n";
		print NONFILE "; name      at.num  mass     charge ptype  sigma      epsilon\n";
	} else {
		if ( $status eq "initial" ) {
			$status = "masstypes";
			open (DOCFILE, "> forcefield.doc");
			print DOCFILE "$line";
			close(DOCFILE);
			open (ATPFILE, "> atomtypes.atp");
		} elsif ( $status eq "masstypes" ) {
			$mass{$_[0]} = $_[1];
			$len = length ($line);
			$pos = index ($line, $_[3]);
			if ( $pos > 0 ) {
				$line = sprintf("%-3s", $_[0]).sprintf("%10.5f",$_[1])." ; ".substr ($line, $pos, $len);
			} else {
				$line = sprintf("%-3s", $_[0]).sprintf("%10.5f",$_[1])."\n";
			}
			print ATPFILE "$line";
		} elsif ( $status eq "hydrophilic" ) {
			$status = "bondtypes";
		} elsif ( $status eq "bondtypes" ) {
			$len = length ($line);
			$line =~ s/-/ /;
			$func = 1;
			@modlin = split (/\s+/, $line);
			$pos = index ($line, $modlin[4]);
			if ( $pos > 0 ) {
				$line = sprintf("%-4s", $modlin[0]).sprintf("%-4s", $modlin[1]).sprintf("%2s", $func).sprintf("%10.5f",0.1*$modlin[3]).sprintf("%12.1f", 100*2*$cal*$modlin[2])." ; ".substr ($line, $pos, $len);
			} else {
				$line = sprintf("%-4s", $modlin[0]).sprintf("%-4s", $modlin[1]).sprintf("%2s", $func).sprintf("%10.5f",0.1*$modlin[3]).sprintf("%12.1f", 100*2*$cal*$modlin[2])."\n";
			}
			print BONFILE1 "$line";
		} elsif ( $status eq "angletypes" ) {
			$len = length ($line);
			$line =~ s/-/ /;
			$line =~ s/-/ /;
			$func = 1;
			@modlin = split (/\s+/, $line);
			$pos = index ($line, $modlin[5]);
			if ( $pos > 0 ) {
				$line = sprintf("%-4s", $modlin[0]).sprintf("%-4s", $modlin[1]).sprintf("%-4s", $modlin[2]).sprintf("%2s", $func).sprintf("%10.3f", $modlin[4]).sprintf("%10.3f", 2*$cal*$modlin[3])." ; ".substr ($line, $pos, $len);
			} else {
				$line = sprintf("%-4s", $modlin[0]).sprintf("%-4s", $modlin[1]).sprintf("%-4s", $modlin[2]).sprintf("%2s", $func).sprintf("%10.3f", $modlin[4]).sprintf("%10.3f", 2*$cal*$modlin[3])."\n";
			}
			print BONFILE1 "$line";
		} elsif ( $status eq "propertypes" ) {
			$len = length ($line);
			$line =~ s/-/ /;
			$line =~ s/-/ /;
			$line =~ s/-/ /;
			$func = 9;
			@modlin = split (/\s+/, $line);
			$pos = index ($line, $modlin[8]);
			if ( $modlin[4] <= 0 ) {
				print "error: IDIVF <= 0 at the line\n";
				print $line;
			}
			if ( $pos > 0 ) {
				$line = sprintf("%-4s", $modlin[0]).sprintf("%-4s", $modlin[1]).sprintf("%-4s", $modlin[2]).sprintf("%-4s", $modlin[3]).sprintf("%2s", $func).sprintf("%8.1f", $modlin[6]).sprintf("%12.5f", $cal*$modlin[5]/$modlin[4]).sprintf("%5.0f", abs($modlin[7]))." ; ".substr ($line, $pos, $len);
			} else {
				$line = sprintf("%-4s", $modlin[0]).sprintf("%-4s", $modlin[1]).sprintf("%-4s", $modlin[2]).sprintf("%-4s", $modlin[3]).sprintf("%2s", $func).sprintf("%8.1f", $modlin[6]).sprintf("%12.5f", $cal*$modlin[5]/$modlin[4]).sprintf("%5.0f", abs($modlin[7]))."\n";
			}
			print BONFILE2 "$line";
		} elsif ( $status eq "impropertypes" ) {
			$len = length ($line);
			$line =~ s/-/ /;
			$line =~ s/-/ /;
			$line =~ s/-/ /;
			$func = 4;
			@modlin = split (/\s+/, $line);
			$pos = index ($line, $modlin[7]);
			if ( $pos > 0 ) {
				$line = sprintf("%-4s", $modlin[0]).sprintf("%-4s", $modlin[1]).sprintf("%-4s", $modlin[2]).sprintf("%-4s", $modlin[3]).sprintf("%2s", $func).sprintf("%8.1f", $modlin[5]).sprintf("%12.5f", $cal*$modlin[4]).sprintf("%5.0f", $modlin[6])." ; ".substr ($line, $pos, $len);
			} else {
				$line = sprintf("%-4s", $modlin[0]).sprintf("%-4s", $modlin[1]).sprintf("%-4s", $modlin[2]).sprintf("%-4s", $modlin[3]).sprintf("%2s", $func).sprintf("%8.1f", $modlin[5]).sprintf("%12.5f", $cal*$modlin[4]).sprintf("%5.0f", $modlin[6])."\n";
			}
			print BONFILE1 "$line";
		} elsif ( $status eq "gap_after_improper" ) {
		} elsif ( $status eq "atomtypes" ) {
			$len = length ($line);
			$atnum = 0;
			if ( substr($_[0],0,2) eq "Na" ) {
				$atnum = 11;
			} elsif ( substr($_[0],0,2) eq "cl" or substr($_[0],0,2) eq "Cl" ) {
				$atnum = 17;
			} elsif ( substr($_[0],0,2) eq "C0" ) {
				$atnum = 20;
			} elsif ( substr($_[0],0,2) eq "br" or substr($_[0],0,2) eq "Br" ) {
				$atnum = 35;
			} elsif ( substr($_[0],0,2) eq "Cs" ) {
				$atnum = 55;
			} elsif ( substr($_[0],0,2) eq "IM" ) {
				$atnum = 17;
			} elsif ( substr($_[0],0,2) eq "IB" ) {
				$atnum = 0;
			} elsif ( substr($_[0],0,1) eq "h" or substr($_[0],0,1) eq "H" ) {
				$atnum = 1;
			} elsif ( substr($_[0],0,1) eq "c" or substr($_[0],0,1) eq "C" ) {
				$atnum = 6;
			} elsif ( substr($_[0],0,1) eq "n" or substr($_[0],0,1) eq "N" ) {
				$atnum = 7;
			} elsif ( substr($_[0],0,1) eq "o" or substr($_[0],0,1) eq "O" ) {
				$atnum = 8;
			} elsif ( substr($_[0],0,1) eq "f" or substr($_[0],0,1) eq "F" ) {
				$atnum = 9;
			} elsif ( substr($_[0],0,1) eq "p" or substr($_[0],0,1) eq "P" ) {
				$atnum = 15;
			} elsif ( substr($_[0],0,1) eq "s" or substr($_[0],0,1) eq "S" ) {
				$atnum = 16;
			} elsif ( substr($_[0],0,1) eq "i" or substr($_[0],0,1) eq "I" ) {
				$atnum = 53;
			}
			$line = sprintf("%-4s", $_[0]).sprintf("%3s", $atnum).sprintf("%8.3f", $mass{$_[0]})."  0.0  A ".sprintf("%13.5e", 0.1*(2**(5/6))*$_[1]).sprintf("%13.5e", $cal*$_[2])." ; ".substr ($line, 41, $len);
			print NONFILE "$line";
		} elsif ( $status eq "end" ) {
			if ( substr($_[0], 0, 3) ne "END") {
				$len = length ($line);
				$line = "; ".substr ($line, 0, $len);
				print DOCFILE "$line";
			}
		}
	}
}
close(DOCFILE);

open (BONFILE2, "< ffbonded2.itp");

while ( <BONFILE2> ) {
	open (BONFILE1, ">> ffbonded.itp");
	$line = $_;
	print BONFILE1 "$line";
}
close (BONFILE2);
close (BONFILE1);

unlink ("ffbonded2.itp");

open (FFFILE, "> forcefield.itp");

print FFFILE "#define _FF_AMBER\n";
print FFFILE "#define _FF_AMBERGENERAL\n";
print FFFILE "\n";
print FFFILE "[ defaults ]\n";
print FFFILE "; nbfunc        comb-rule       gen-pairs       fudgeLJ fudgeQQ\n";
print FFFILE "1               2               yes             0.5     0.8333\n";
print FFFILE "\n";
print FFFILE "#include \"ffnonbonded.itp\"\n";
print FFFILE "#include \"ffbonded.itp\"\n";

close (FFFILE);
