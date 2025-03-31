// Eyeshadow Palette Generator V18.4 (Base + Lid Combined + Horizontal Gap, Dynamic Lid Thickness)

// --- Input Variables ---
rowCount = 3;          // Number of rows for eyeshadow pans
columnCount = 4;       // Number of columns for eyeshadow pans
eyeshadowDiameter = 26; // Diameter of each eyeshadow pan cutout (in mm)

// --- Design Parameters (Adjust as needed) ---
// Base Parameters
innerPadding = 5;      // Space ONLY between pans (mm)
eyeshadowDepth = 3;    // How deep the circular recess for the pan is (mm)
pushHoleDiameter = 3;  // Diameter of the small hole for pushing pans out (mm)
magnetDiameter = 6;    // Diameter of the magnet hole (mm)
magnetHeight = 2;      // Explicit height/depth of the magnet hole (mm)
magnetHoleBottomClearance = 1; // Minimum material thickness below BASE magnet hole (mm)
cornerMagnetWallGap = 2; // Static gap between corner magnet edge and palette wall (mm)
// Lid Parameters
// lidThickness = 3;       // REMOVED - Now calculated dynamically
lidMagnetTopClearance = 1; // **NEW: Minimum material thickness ABOVE lid magnet hole (mm)**
lidPreviewGap = 5;      // **MODIFIED: Horizontal gap between base and lid in preview (mm)**
// Alignment Guide Bar Parameters
barHeight = 2;         // Height of the guide bars on base (mm)
barThickness = 1.5;      // Thickness of the guide bars (mm)
barEndGap = 10;        // Gap between bar end and corner magnet center (mm)
alignmentTolerance = 0.1;// Extra space in lid grooves for tolerance (mm)

// --- Calculated Values ---
eyeshadowRadius = eyeshadowDiameter / 2;
magnetRadius = magnetDiameter / 2; // This will be 3
pushHoleRadius = pushHoleDiameter / 2;

// --- Dynamic Margin Calculation ---
outerMargin = magnetDiameter + cornerMagnetWallGap; // e.g., 6 + 2 = 8

// --- Pan Magnet Hole Offset Parameters ---
magnetOffsetX = eyeshadowRadius / 2; // Offset distance in X from pan center
magnetOffsetY = 0;                   // Offset distance in Y from pan center

// --- Quality ---
smoothness = 50;       // $fn value for smoother circles.

// --- Calculate Palette Base Thickness ---
paletteThickness = eyeshadowDepth + magnetHeight + magnetHoleBottomClearance;
echo("INFO: Calculated Palette Base Thickness = ", paletteThickness); // e.g., 3 + 2 + 1 = 6

// --- Calculate Lid Thickness Dynamically ---
lidThickness = magnetHeight + lidMagnetTopClearance; // **NEW CALCULATION**
echo("INFO: Calculated Lid Thickness = ", lidThickness); // e.g., 2 + 1 = 3

// --- Assertions (Safety Checks) ---
assert(rowCount > 0, "ERROR: rowCount must be positive.");
assert(columnCount > 0, "ERROR: columnCount must be positive.");
assert(innerPadding >= 0, "ERROR: innerPadding cannot be negative.");
assert(outerMargin > 0, "ERROR: outerMargin must be positive.");
assert(cornerMagnetWallGap >= 0, "ERROR: cornerMagnetWallGap cannot be negative.");
assert(barHeight > 0, "ERROR: barHeight must be positive.");
assert(barThickness > 0, "ERROR: barThickness must be positive.");
assert(barEndGap >= 0, "ERROR: barEndGap cannot be negative.");
assert(alignmentTolerance >= 0, "ERROR: alignmentTolerance cannot be negative.");
assert(eyeshadowDepth > 0, "ERROR: eyeshadowDepth must be positive.");
assert(magnetHeight > 0, "ERROR: magnetHeight must be positive.");
assert(magnetHoleBottomClearance >= 0, "ERROR: magnetHoleBottomClearance cannot be negative.");
assert(lidMagnetTopClearance >= 0, "ERROR: lidMagnetTopClearance cannot be negative."); // New assertion
assert(paletteThickness > 0, "Calculated palette thickness is not positive.");
assert(lidThickness > 0, "Calculated lid thickness is not positive."); // Check calculated value
assert(lidPreviewGap >= 0, "ERROR: lidPreviewGap cannot be negative.");
// assert(lidThickness >= magnetHeight, ...); // Always true now by definition

// Check if outerMargin is large enough for magnet placement
assert(outerMargin >= magnetRadius + cornerMagnetWallGap, str("ERROR: outerMargin (", outerMargin, ") is too small for corner magnet offset (radius ", magnetRadius, " + gap ", cornerMagnetWallGap, ")."));

// Check pan magnet offset isn't too large
assert(magnetDiameter / 2 + abs(magnetOffsetX) < eyeshadowRadius, str("ERROR: Pan Magnet offset X too large."));
assert(magnetDiameter / 2 + abs(magnetOffsetY) < eyeshadowRadius, str("ERROR: Pan Magnet offset Y too large."));
// Check corner magnet placement respects bottom clearance in base
assert(paletteThickness - magnetHeight >= magnetHoleBottomClearance - 0.01, "ERROR: Base thickness insufficient for corner magnet height/clearance.");

// --- Derived Palette Dimensions (Used by both modules) ---
paletteWidth = (columnCount * eyeshadowDiameter) + (max(0, columnCount - 1) * innerPadding) + (2 * outerMargin);
paletteLength = (rowCount * eyeshadowDiameter) + (max(0, rowCount - 1) * innerPadding) + (2 * outerMargin);
epsilon = 0.01; // Small value for clean boolean operations

// --- Alignment Feature Calculations ---
// Corner magnet center offset from corner
corner_magnet_center_offset = magnetRadius + cornerMagnetWallGap; // e.g., 3 + 2 = 5
// Bar position offsets (align bar centerline with magnet center)
bar_outer_offset = corner_magnet_center_offset - (barThickness / 2); // e.g., 5 - (1.5 / 2) = 4.25
bar_inner_offset = bar_outer_offset + barThickness; // e.g., 4.25 + 1.5 = 5.75

// Calculate dynamic bar start positions and lengths
bar_start_X = corner_magnet_center_offset + barEndGap; // Start after left magnet + gap
bar_end_X   = paletteWidth - corner_magnet_center_offset - barEndGap; // End before right magnet - gap
bar_length_X = bar_end_X - bar_start_X; // Calculate length

bar_start_Y = corner_magnet_center_offset + barEndGap; // Start after bottom magnet + gap
bar_end_Y   = paletteLength - corner_magnet_center_offset - barEndGap; // End before top magnet - gap
bar_length_Y = bar_end_Y - bar_start_Y; // Calculate length

// Assert guide bar placement is reasonable
assert(bar_outer_offset >= 0, "ERROR: barThickness is too large to center the bar on the corner magnet axis.");
assert(bar_inner_offset < paletteWidth / 2 && bar_inner_offset < paletteLength / 2, "ERROR: Guide bars offset extends too far inwards.");
// Assert calculated lengths are positive
assert(bar_length_X > 0, str("ERROR: Calculated horizontal bar length is not positive (", bar_length_X,"). barEndGap might be too large."));
assert(bar_length_Y > 0, str("ERROR: Calculated vertical bar length is not positive (", bar_length_Y,"). barEndGap might be too large."));


// --- Module Definition: Palette Base ---
module palette_base() {
    union() {
        // Part 1: Base with holes
        difference() {
            cube([paletteWidth, paletteLength, paletteThickness]);
            // Subtract pan holes, pan magnets, push holes
            for (r = [0 : rowCount - 1]) {
                for (c = [0 : columnCount - 1]) {
                    x_pos = outerMargin + eyeshadowRadius + c * (eyeshadowDiameter + innerPadding);
                    y_pos = outerMargin + eyeshadowRadius + r * (eyeshadowDiameter + innerPadding);
                    translate([x_pos, y_pos, paletteThickness - eyeshadowDepth - epsilon]) cylinder(h = eyeshadowDepth + 2 * epsilon, r = eyeshadowRadius, $fn = smoothness);
                    translate([x_pos + magnetOffsetX, y_pos + magnetOffsetY, paletteThickness - eyeshadowDepth - magnetHeight - epsilon]) cylinder(h = magnetHeight + 2 * epsilon, r = magnetRadius, $fn = smoothness);
                    translate([x_pos, y_pos, -epsilon]) cylinder(h = paletteThickness + 2 * epsilon, r = pushHoleRadius, $fn = smoothness);
                }
            }
            // Subtract Corner Magnet Holes
            corner_pos = [
                [corner_magnet_center_offset, corner_magnet_center_offset],
                [paletteWidth - corner_magnet_center_offset, corner_magnet_center_offset],
                [corner_magnet_center_offset, paletteLength - corner_magnet_center_offset],
                [paletteWidth - corner_magnet_center_offset, paletteLength - corner_magnet_center_offset]
            ];
            for (pos = corner_pos) {
                translate([pos[0], pos[1], paletteThickness - magnetHeight - epsilon]) cylinder(h = magnetHeight + 2 * epsilon, r = magnetRadius, $fn = smoothness);
            }
        } // End Part 1

        // Part 2: Add the Guide Bars on Top (Dynamic Length with Gap, Axis-Aligned Position)
        bar_z = paletteThickness; // Bars sit on top of base
        // Bottom Bar
        translate([bar_start_X, bar_outer_offset, bar_z])
            cube([bar_length_X, barThickness, barHeight]);
        // Top Bar
        translate([bar_start_X, paletteLength - bar_outer_offset - barThickness, bar_z])
            cube([bar_length_X, barThickness, barHeight]);
        // Left Bar
        translate([bar_outer_offset, bar_start_Y, bar_z])
            cube([barThickness, bar_length_Y, barHeight]);
        // Right Bar
        translate([paletteWidth - bar_outer_offset - barThickness, bar_start_Y, bar_z])
            cube([barThickness, bar_length_Y, barHeight]);

    } // End Base Union
}

// --- Module Definition: Palette Lid ---
module palette_lid() {
    difference() {
        // 1. Create the main lid rectangle - USES CALCULATED lidThickness
        cube([paletteWidth, paletteLength, lidThickness], center = false);

        // 2. Subtract Corner Magnet Holes
        corner_pos = [
            [corner_magnet_center_offset, corner_magnet_center_offset],
            [paletteWidth - corner_magnet_center_offset, corner_magnet_center_offset],
            [corner_magnet_center_offset, paletteLength - corner_magnet_center_offset],
            [paletteWidth - corner_magnet_center_offset, paletteLength - corner_magnet_center_offset]
        ];
        lid_magnet_z_bottom = 0;
        for (pos = corner_pos) {
            translate([pos[0], pos[1], lid_magnet_z_bottom - epsilon]) {
                cylinder(h = magnetHeight + 2 * epsilon, r = magnetRadius, $fn = smoothness);
            }
        }

        // 3. Subtract Grooves for Guide Bars (Dynamic Length with Gap, Axis-Aligned Position)
        groove_z = -epsilon; // Start slightly below lid bottom
        groove_depth = barHeight + 2 * epsilon; // Make slightly deeper
        tol = alignmentTolerance; // Now uses 0.1

        // Bottom Groove
        translate([bar_start_X - tol, bar_outer_offset - tol, groove_z])
            cube([bar_length_X + 2*tol, barThickness + 2*tol, groove_depth]);
        // Top Groove
        translate([bar_start_X - tol, paletteLength - bar_outer_offset - barThickness - tol, groove_z])
            cube([bar_length_X + 2*tol, barThickness + 2*tol, groove_depth]);
        // Left Groove
        translate([bar_outer_offset - tol, bar_start_Y - tol, groove_z])
            cube([barThickness + 2*tol, bar_length_Y + 2*tol, groove_depth]);
        // Right Groove
        translate([paletteWidth - bar_outer_offset - barThickness - tol, bar_start_Y - tol, groove_z])
            cube([barThickness + 2*tol, bar_length_Y + 2*tol, groove_depth]);

    } // End Lid Difference
}

// --- Instantiate Modules ---

// Generate the base at the origin
palette_base();

// Generate the lid, rotate it upside down, and place it BESIDE the base
translate([0, -lidPreviewGap, lidThickness]) { // ** MODIFIED: Horizontal gap on X-axis, Z=0 **
    rotate([180, 0, 0]) { // Rotate lid 180 deg around X-axis
        palette_lid();
    }
}

// --- End of Script ---
