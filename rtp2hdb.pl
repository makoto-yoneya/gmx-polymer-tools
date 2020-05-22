#!/usr/bin/perl

#    rtp2hdb.pl	M.Yoneya   04.22.2020 

$nair = 0;
$aname_n[0] = "NULL";
$aname_c[0] = "NULL";

$nbn = 1;
$nbc = 1;

$mode_n = 1;
$mode_c = 1;

for ( $scan = 1; $scan <= 5; $scan++ ) { 

	$status = "initial";
	$ia = 0;
	$ib = 0;
	$ir = 0;
	
	while ( <> ) {
		$line = $_; 
		chomp $_;
		if ( $_ =~ m/^\s+(.*)/ ) {
			$_ = $1;
		}
	
		@_ = split (/\s+/, $_);
	
		if ( $_[0] eq "[" and  $_[2] eq "]" ) {
			if ( $_[1] eq "atoms" ) {
				$ia++;
			} elsif ( $_[1] eq "bonds" ) {
				$ib++;
			} else {
				$ir++;
				if ( $ir == 1 ) {
					$mname_n = $_[1];
				} 
				elsif ( $ir == 3 ) {
					$mname_c = $_[1];
				}
			}
			$status = $_[1];
		} elsif ( $status eq "atoms" ) {
			if ( $scan == 1 ) {
				if ( $ir == 2 ) {
					$nair++;
					$aname[$nair] = $_[0]; 
				}
			}
			elsif ( $scan == 2 ) {
				if ( $ir == 1 && $aname_n[0] eq "NULL" ) {
					for ( $i = 1; $i <= $nair; $i++ ) { 
						if ( $_[0] eq $aname[$i] ) {
							last;
						}
					}
					if ( $i > $nair ) {
						$aname_n[0] = $_[0];
					}
				}
				elsif ( $ir == 3 && $aname_c[0] eq "NULL" ) {
					for ( $i = 1; $i <= $nair; $i++ ) { 
						if ( $_[0] eq $aname[$i] ) {
							last;
						}
					}
					if ( $i > $nair ) {
						$aname_c[0] = $_[0];
					}
				}
			}
		} elsif ( $status eq "bonds" ) {
			if ( $scan == 3 ) {
				if ( $ir == 1 ) {
					if ( $_[0] eq $aname_n[0] ) {
						$aname_n[1] = $_[1];
					}
					elsif ( $_[1] eq $aname_n[0] ) {
						$aname_n[1] = $_[0];
					}
				}
				elsif ( $ir == 3 ) {
					if ( $_[0] eq $aname_c[0] ) {
						$aname_c[1] = $_[1];
					}
					elsif ( $_[1] eq $aname_c[0] ) {
						$aname_c[1] = $_[0];
					}
				}
			}
			elsif ( $scan == 4 ) {
				if ( $ir == 1 ) {
					if ( $_[0] eq $aname_n[1] && $_[1] ne $aname_n[0] ) {
						$nbn++;
						$aname_n[$nbn] = $_[1];
					}
					elsif ( $_[1] eq $aname_n[1] && $_[0] ne $aname_n[0] ) {
						$nbn++;
						$aname_n[$nbn] = $_[0];
					}
				}
				elsif ( $ir == 3 ) {
					if ( $_[0] eq $aname_c[1] && $_[1] ne $aname_c[0] ) {
						$nbc++;
						$aname_c[$nbc] = $_[1];
					}
					elsif ( $_[1] eq $aname_c[1] && $_[0] ne $aname_c[0] ) {
						$nbc++;
						$aname_c[$nbc] = $_[0];
					}
				}
			}
			elsif ( $scan == 5 ) {
				if ( $ir == 1 ) {
					if ( $nbn < 3 ) {
						$mode_n = 2;
						if ( $_[0] eq $aname_n[2] && $_[1] ne $aname_n[0]  && $_[1] ne $aname_n[1] && $_[1] ne $aname_n[2] ) {
							$nbn++;
							$aname_n[$nbn] = $_[1];
						}
						elsif ( $_[1] eq $aname_n[2] && $_[0] ne $aname_n[0] && $_[0] ne $aname_n[1] && $_[0] ne $aname_n[2] ) {
							$nbn++;
							$aname_n[$nbn] = $_[0];
						}
					}
				}
				elsif ( $ir == 3 ) {
					if ( $nbc < 3 ) {
						$mode_c = 2;
						if ( $_[0] eq $aname_c[2] && $_[1] ne $aname_c[0] && $_[1] ne $aname_c[1] && $_[1] ne $aname_c[2] ) {
							$nbc++;
							$aname_c[$nbc] = $_[1];
						}
						elsif ( $_[1] eq $aname_c[2] && $_[0] ne $aname_c[0] && $_[0] ne $aname_c[1] && $_[0] ne $aname_c[2] ) {
							$nbc++;
							$aname_c[$nbc] = $_[0];
						}
					}
				}
			}
		}
	}

	seek(STDIN,0,0);
}

#print "$nbn\n";
#for ( $i = 0; $i <= $nbn; $i++ ) { 
#	print "$aname_n[$i]\n";
#}
#print "$nbc\n";
#for ( $i = 0; $i <= $nbc; $i++ ) { 
#	print "$aname_c[$i]\n";
#}

printf "%-10s%-5d\n", $mname_n, 1; 
printf "%-5d%-5d%-6s%-6s%-6s%-6s\n", 1, $mode_n, $aname_n[0], $aname_n[1], $aname_n[2] ,$aname_n[3]; 

printf "%-10s%-5d\n", $mname_c, 1; 
printf "%-5d%-5d%-6s%-6s%-6s%-6s\n", 1, $mode_c, $aname_c[0], $aname_c[1], $aname_c[2] ,$aname_c[3]; 
