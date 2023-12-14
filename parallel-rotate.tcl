# Enable the main menu
menu main on

# Load molecular structure files
mol new 60f.psf
mol addfile 60f.pdb

# Aligning with x and y axis

# Import required package and namespace
package require Orient
namespace import Orient::orient

# Select all atoms and move to the center of the coordinate system
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

# Translate along the y-axis
set first_y [transaxis y 10]
$sel move $first_y

# Get a sorted list of unique residues
set residues [lsort -integer -unique [$sel get residue]]

# Number of residues in each sheet
set res_beg 0
set res_end 29

# Initialize variables for displacement and rotation
set cumulative_displacement {0 0 0}
set cumulative_rotation_angle 0.0
set cumulative_matrix {1.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0}

# Move and rotate residues in the first sheet
foreach residue [lrange $residues $res_beg [expr {$res_beg + $res_end}]] {
    set res_atoms [atomselect top "residue $residue"]
    $res_atoms moveby $cumulative_displacement
    set cumulative_displacement [vecadd $cumulative_displacement {0 0 4.5}]
    set cumulative_matrix [transaxis z $cumulative_rotation_angle]
    $res_atoms move $cumulative_matrix
    set cumulative_rotation_angle [expr {$cumulative_rotation_angle + 5.0}]
}

# Second sheet

set res_beg_2 30
set res_end_2 59

# Distance between two sheets, and oxygens out
set cumulative_displacement_2 {11 0 0}

# Move and displace residues in the second sheet
foreach residue [lrange $residues $res_beg_2 [expr {$res_beg_2 + $res_end_2}]] {
    set res_atoms [atomselect top "residue $residue"]
    set y [transaxis y 180]
    $res_atoms move $y
    $res_atoms moveby $cumulative_displacement_2
    set cumulative_displacement_2 [vecadd $cumulative_displacement_2 {0 0 4.5}]
}

# Rotate residues in the second sheet to make antiparallel sheets
set residue_rot_list {30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59}

set cumulative_rotation_angle_2 0.0
set cumulative_matrix_2 {1.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0}

foreach residue_rot $residue_rot_list {
    set clean_res_1 [atomselect top "residue $residue_rot"]
    set res_1 [measure center $clean_res_1]
    set inverted_res_1 [list 0 0 [expr {-[lindex $res_1 2]}]]
    $clean_res_1 moveby $inverted_res_1
    set clean_rot_1 [transaxis x 180]
    $clean_res_1 move $clean_rot_1
    set inverted_2_res_1 [list 0 0 [lindex $res_1 2]]
    $clean_res_1 moveby $inverted_2_res_1
    set cumulative_matrix_2 [transaxis z $cumulative_rotation_angle_2]
    $clean_res_1 move $cumulative_matrix_2
    set cumulative_rotation_angle_2 [expr {$cumulative_rotation_angle_2 + 5.0}]
}

# Write PSF and PDB files
[atomselect top all] writepsf arranged.psf
[atomselect top all] writepdb arranged.pdb

exit
