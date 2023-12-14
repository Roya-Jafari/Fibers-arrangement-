# Enable the main menu
menu main on

# Load molecular structure files
mol new 60f.psf
mol addfile 60f.pdb

# Import required package and namespace
package require Orient
namespace import Orient::orient

# Select all atoms and move them to the center of the coordinate system
set sel [atomselect top all]
set cent [measure center $sel]
set inverted_vec [vecinvert $cent]
$sel moveby $inverted_vec
set new_center [measure center $sel]

# Draw principal axes, orient the molecule along them, and move it
set I [draw principalaxes $sel]
set A [orient $sel [lindex $I 2] {1 0 0}]
$sel move $A
set II [draw principalaxes $sel]
set AA [orient $sel [lindex $II 2] {0 1 0}]
$sel move $AA

# Translate and rotate the molecule along specified axes
set first_y [transaxis y 10]
set first_z [transaxis z 2]
$sel move $first_y
$sel move $first_z

# Get a sorted list of unique residues
set residues [lsort -integer -unique [$sel get residue]]

# Move and displace selected residues
set res_beg 0
set res_end 29
set cumulative_displacement {0 0 0}

foreach residue [lrange $residues $res_beg [expr {$res_beg + $res_end}]] {
    set res_atoms [atomselect top "residue $residue"]
    $res_atoms moveby $cumulative_displacement
    set cumulative_displacement [vecadd $cumulative_displacement {0 0 4.5}]
}

# Move and displace another set of residues
set res_beg_2 30
set res_end_2 59
set cumulative_displacement_2 {9 2 0}

foreach residue [lrange $residues $res_beg_2 [expr {$res_beg_2 + $res_end_2}]] {
    set res_atoms [atomselect top "residue $residue"]
    set y [transaxis y 180]
    $res_atoms move $y
    $res_atoms moveby $cumulative_displacement_2
    set cumulative_displacement_2 [vecadd $cumulative_displacement_2 {0 0 4.5}]
}

# Comment out other two set of numbers and use only one set based on your desired structure
# Make all of the fibers anti-parallel
set residue_rot_list {1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60}
# Make sheets anti-parallel
set residue_rot_list {30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59}
# Make all of the fibers parallel
set residue_rot_list {}

foreach residue_rot $residue_rot_list {
	set clean_res_1 [atomselect top "residue $residue_rot"]
        set res_1 [measure center $clean_res_1]
        set inverted_res_1 [list 0 0 [expr {-[lindex $res_1 2]}]]
        $clean_res_1 moveby $inverted_res_1
        set clean_rot_1 [transaxis x 180]
        $clean_res_1 move $clean_rot_1
        set inverted_2_res_1 [list 0 0 [lindex $res_1 2]]
        $clean_res_1 moveby $inverted_2_res_1
}

# Move selected atom groups
set mono [atomselect top "residue 0 31"]
$mono writepsf monomer.psf
$mono writepdb monomer.pdb

# Write PSF and PDB of final arrangement
[atomselect top all] writepsf arranged.psf
[atomselect top all] writepdb arranged.pdb

# Exit vmd
exit
