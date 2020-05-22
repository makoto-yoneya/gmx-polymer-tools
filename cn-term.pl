#!/usr/bin/perl

#    c_n-term.pl	M.Yoneya   23.04.2020 

$nres = 0;

while ( <> ) {
	$line = $_; 
	chomp $_;
	if ( $_ =~ m/^\s+(.*)/ ) {
		$_ = $1;
	}

	@_ = split (/\s+/, $_);

	if ( $_[0] eq "ATOM" ) {
		$nres = $_[4];
	}
}

#print "$nres\n";

if ( $nres <= 1 ) {
	die "Number of residues is <= 1\n";
}

seek(STDIN,0,0);

while ( <> ) {
	$line = $_; 
	chomp $_;
	if ( $_ =~ m/^\s+(.*)/ ) {
		$_ = $1;
	}

	@_ = split (/\s+/, $_);

	if ( $_[0] eq "ATOM" ) {
		if ( $_[4] == 1 ) {
			if ( substr($_[3], 0, 1) eq "n" ) {
				$rname = $_[3];
			} elsif ( substr($_[3], 0, 1) eq "c" ) {
				$rname = substr($_[3], 1); 
				$rname = "n".$rname; 
			} else {
				$rname = "n".$_[3]; 
			}
		} elsif ( $_[4] == $nres ) {
			if ( substr($_[3], 0, 1) eq "c" ) {
				$rname = $_[3];
			} elsif ( substr($_[3], 0, 1) eq "n" ) {
				$rname = substr($_[3], 1); 
				$rname = "c".$rname; 
			} else {
				$rname = "c".$_[3]; 
			}
		} else {
			if ( substr($_[3], 0, 1) eq "c" ) {
				$rname = substr($_[3], 1); 
			} elsif ( substr($_[3], 0, 1) eq "n" ) {
				$rname = substr($_[3], 1); 
			} else {
				$rname = $_[3]; 
			}
		}
		printf "%-6s%5d %-4s %-4s %4d    %8s%8s%8s\n", $_[0], $_[1], $_[2], $rname, $_[4], $_[5], $_[6], $_[7];
	} else {
		print $line;
	}
}
