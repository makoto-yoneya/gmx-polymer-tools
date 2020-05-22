#!/usr/bin/perl

#    mol22rtp.pl	M.Yoneya   08.07.2015 

$status = "initial";

while ( <> ) {
	$line = $_; 
	chomp $_;
	if ( $_ =~ m/^\s+(.*)/ ) {
		$_ = $1;
	}

	@_ = split (/\s+/, $_);

	if ( $_[0] eq "@<TRIPOS>MOLECULE"  ) {
		$status = "molecule";
	} elsif ( $_[0] eq "@<TRIPOS>ATOM"  ) {
		$status = "atom";
		print "  [ atoms ]\n";
	} elsif ( $_[0] eq "@<TRIPOS>BOND"  ) {
		$status = "bond";
		print "  [ bonds ]\n";
	} elsif ( $_[0] eq "@<TRIPOS>SUBSTRUCTURE"  ) {
		$status = "end";
	} elsif ( $status eq "molecule" ) {
		print "[ ".$_[0]." ]\n";
		$status = "gap_after_molecule";
	} elsif ( $status eq "atom" ) {
		@modlin = split (/\s+/, $line);
		$atomname[$modlin[1]] = $modlin[2];
		$line = "    ".sprintf("%-6s", $modlin[2]).sprintf("%-6s", $modlin[6]).sprintf("%10.5f", $modlin[9]).sprintf("%6s", $modlin[7])."\n";
		print $line;
	} elsif ( $status eq "bond" ) {
		@modlin = split (/\s+/, $line);
		$line = "    ".sprintf("%-6s", $atomname[$modlin[2]]).sprintf("%-6s", $atomname[$modlin[3]])."\n";
		print $line;
	}
}
