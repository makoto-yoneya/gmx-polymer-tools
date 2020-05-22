# gmx-polymer-tools

Perl scripts for polymer modeling using GROMACS

## Functions

These Perl scripts help to model synthetic polymers using [GROMACS][1]

These are 

- mol22rtp.pl : translates [sybyl-mol2 format][2] file (\*.mol2) to GROMACS [residue topology format][3] file (\*.rtp)  

- rtp2tmer.pl : translates plain rtp format file (\*.rtp) of trimer to real rtp file (\*.rtp) 

- rtp2hdb.pl : create [hydrogen databese][4] file (\*.hdb) for the terminal residues from the real rtp file (\*.rtp) 

- pdb2tmer.pl : create plain pdb format file (\*.pdb) of trimer to the trimer pdb file (\*.pdb) for [pdb2gmx][5]

- cn-term.pl : translate pdb file's the first and the last residues to be the terminal residues.

And additionally, 

- ambdat2gmx.pl : translates [AMBER force field parameter file][6] (\*.dat) to GROMACS forcefiled data files (\*.itp, \*.atp) 

- frcmod2gmx.pl :translates [AMBER parameter modification file][7] (\*.frcmod) to GROMACS forcefiled data files (\*.itp, \*.atp).

These two scripts are not specifically for polymer modeling, but help to provide general AMBER (GAFF) force fields for GROMACS pdb2gmx. 

## Usage

`mol22rtp.pl < 3lla.mol2 > 3lla.rtp`

Input \*.mol2 file is assumed to be generated with [antechamber][3] with proper force field (e.g. GAFF) atom types and charges.

Resultant plain \*.rtp file can be input for rtp2tmer.pl as,

`rtp2tmer.pl -n 7 -c 29 < 3lla.rtp > lla.rtp`

Resultant lla.rtp is the final residue topology files for the monomar (here lla, L-lactic acid) as new residue.

Corresponding hydrogen databese file (\*.hdb) for the terminal residues can be created from this rtp file.

`rtp2hdb.pl < lla.rtp > lla.hdb`

Trimer pdb file (3lla.pdb) can be translated to the pdb file suitable for pdb2gmx by

`pdb2tmer.pl -n 7 -c 29 < 3lla.pdb > 3lla_4pdb2gmx.pdb`

Simple 60 mer pdb file (60lla.pdb) can be translated with

`cn-term.pl < 60lla.pdb > 60lla_4pdb2gmx.pdb`

to obtain pdb file suitable for pdb2gmx as

`gmx pdb2gmx -f 60lla_4pdb2gmx.pdb -o 60lla.gro -ff gaff -water none`

An example of these modeing flow can be found in [this tutorial][8] (in Japanese).

To obtain GROMACS force field data files (in gaff.ff directory) from AMBER force field prarameter file for general AMBER force field (GAFF), 

`mkdir gaff.ff && cd gaff.ff`

`ambdat2gmx.pl < gaff.dat`

This creates  

- atomtypes.atp

- ffbonded.itp

- ffnonbonded.itp

- forcefield.doc

- forcefield.itp

Resultant gaff.ff can be used for pdb2gmx.

To obtain GROMACS force field data files from AMBER parameter modification file,

`frcmod2gmx.pl < 3lla.frcmod`

This creates  

- frcmod_atomtypes.atp

- frcmod_ffbonded.itp

- frcmod_ffnonbonded.itp

## Prerequisites

Perl interpleater.

## Authors

Makoto Yoneya.

[1]: http://www.gromacs.org/Documentation_of_outdated_version/How-tos/Polymers 
[2]: http://www.csb.yale.edu/userguides/datamanip/dock/DOCK_4.0.1/html/Manual.41.html
[3]: http://manual.gromacs.org/documentation/2019/reference-manual/file-formats.html#rtp
[4]: http://manual.gromacs.org/documentation/2019/reference-manual/topologies/pdb2gmx-input-files.html#hydrogen-database
[5]: http://manual.gromacs.org/documentation/current/onlinehelp/gmx-pdb2gmx.html
[6]: https://ambermd.org/FileFormats.php#parm.dat
[7]: https://ambermd.org/FileFormats.php#frcmod
[8]: https://makoto-yoneya.github.io/MDforPOLYMERS/
