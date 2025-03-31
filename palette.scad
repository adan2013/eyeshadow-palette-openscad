// Eyeshadow Palette Generator V19

/*[Pans]*/
// First diameter
dimensionA = 3; // [1:1:6]
// second diameter
dimensionB = 2; // [1:1:6]
// pan diameter in mm
panDiameter = 26; // [20:1:40]
// depth of the pans in mm
panDepth = 3; // [3:1:6]

/*[Magnets and push holes]*/
magnetDiameter = 6; // [5:1:10]
magnetHeight = 2; // [1:1:4]
pushHoleDiameter = 3; // [3:1:6]

/*[Spacing]*/
cornerMargin = 3; // [2:1:10]
panSpacing = 6; // [3:1:10]

/*[Hidden]*/
rowCount = min(dimensionA, dimensionB);
columnCount = max(dimensionA, dimensionB);

magnetHoleClearance = 1;
railHeight = 1;
railThickness = 1;
railMagnetOffset = 10;

panRadius = panDiameter / 2;
magnetRadius = magnetDiameter / 2;
pushHoleRadius = pushHoleDiameter / 2;

outerMargin = magnetDiameter + cornerMargin;
magnetOffsetX = panRadius / 2;
magnetOffsetY = 0;
pushHoleOffsetX = panRadius / -2;
pushHoleOffsetY = 0;

lidThickness = magnetHeight + magnetHoleClearance;
paletteThickness = panDepth + magnetHeight + magnetHoleClearance;
paletteWidth = (columnCount * panDiameter) + (max(0, columnCount - 1) * panSpacing) + (2 * outerMargin);
paletteLength = (rowCount * panDiameter) + (max(0, rowCount - 1) * panSpacing) + (2 * outerMargin);

epsilon = 0.01;
gap = 0.2;
lidPreviewGap = 5;
smoothness = 50;

echo("DEBUG: Palette thickness = ", paletteThickness);
echo("DEBUG: Lid thickness = ", lidThickness);

assert(rowCount > 0, "ERROR: rowCount must be positive.");
assert(columnCount > 0, "ERROR: columnCount must be positive.");
assert(panSpacing >= 0, "ERROR: panSpacing cannot be negative.");
assert(cornerMargin >= 0, "ERROR: cornerMargin cannot be negative.");
assert(railHeight > 0, "ERROR: railHeight must be positive.");
assert(railThickness > 0, "ERROR: railThickness must be positive.");
assert(railMagnetOffset >= 0, "ERROR: railMagnetOffset cannot be negative.");
assert(panDepth > 0, "ERROR: panDepth must be positive.");
assert(magnetHeight > 0, "ERROR: magnetHeight must be positive.");
assert(magnetHoleClearance >= 0, "ERROR: magnetHoleClearance cannot be negative.");

// --- Alignment Feature Calculations ---
// Corner magnet center offset from corner
corner_magnet_center_offset = magnetRadius + cornerMargin; // e.g., 3 + 2 = 5
// Bar position offsets (align bar centerline with magnet center)
bar_outer_offset = corner_magnet_center_offset - (railThickness / 2); // e.g., 5 - (1.5 / 2) = 4.25
bar_inner_offset = bar_outer_offset + railThickness; // e.g., 4.25 + 1.5 = 5.75

// Calculate dynamic bar start positions and lengths
bar_start_X = corner_magnet_center_offset + railMagnetOffset; // Start after left magnet + gap
bar_end_X   = paletteWidth - corner_magnet_center_offset - railMagnetOffset; // End before right magnet - gap
bar_length_X = bar_end_X - bar_start_X; // Calculate length

bar_start_Y = corner_magnet_center_offset + railMagnetOffset; // Start after bottom magnet + gap
bar_end_Y   = paletteLength - corner_magnet_center_offset - railMagnetOffset; // End before top magnet - gap
bar_length_Y = bar_end_Y - bar_start_Y; // Calculate length

// Assert guide bar placement is reasonable
assert(bar_outer_offset >= 0, "ERROR: railThickness is too large to center the bar on the corner magnet axis.");
assert(bar_inner_offset < paletteWidth / 2 && bar_inner_offset < paletteLength / 2, "ERROR: Guide bars offset extends too far inwards.");
// Assert calculated lengths are positive
assert(bar_length_X > 0, str("ERROR: Calculated horizontal bar length is not positive (", bar_length_X,"). railMagnetOffset might be too large."));
assert(bar_length_Y > 0, str("ERROR: Calculated vertical bar length is not positive (", bar_length_Y,"). railMagnetOffset might be too large."));


// --- Module Definition: Palette Base ---
module palette_base() {
    union() {
        // Part 1: Base with holes
        difference() {
            cube([paletteWidth, paletteLength, paletteThickness]);
            // Subtract pan holes, pan magnets, push holes
            for (r = [0 : rowCount - 1]) {
                for (c = [0 : columnCount - 1]) {
                    x_pos = outerMargin + panRadius + c * (panDiameter
                 + panSpacing);
                    y_pos = outerMargin + panRadius + r * (panDiameter
                 + panSpacing);
                    translate([x_pos, y_pos, paletteThickness - panDepth - epsilon]) cylinder(h = panDepth + 2 * epsilon, r = panRadius, $fn = smoothness);
                    translate([x_pos + magnetOffsetX, y_pos + magnetOffsetY, paletteThickness - panDepth - magnetHeight - epsilon]) cylinder(h = magnetHeight + 2 * epsilon, r = magnetRadius, $fn = smoothness);
                    translate([x_pos + pushHoleOffsetX, y_pos + pushHoleOffsetY, -epsilon]) cylinder(h = paletteThickness + 2 * epsilon, r = pushHoleRadius, $fn = smoothness);
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
            cube([bar_length_X, railThickness, railHeight
        ]);
        // Top Bar
        translate([bar_start_X, paletteLength - bar_outer_offset - railThickness, bar_z])
            cube([bar_length_X, railThickness, railHeight
        ]);
        // Left Bar
        translate([bar_outer_offset, bar_start_Y, bar_z])
            cube([railThickness, bar_length_Y, railHeight
        ]);
        // Right Bar
        translate([paletteWidth - bar_outer_offset - railThickness, bar_start_Y, bar_z])
            cube([railThickness, bar_length_Y, railHeight
        ]);

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
        groove_depth = railHeight
     + 2 * epsilon; // Make slightly deeper
        tol = gap; // Now uses 0.1

        // Bottom Groove
        translate([bar_start_X - tol, bar_outer_offset - tol, groove_z])
            cube([bar_length_X + 2*tol, railThickness + 2*tol, groove_depth]);
        // Top Groove
        translate([bar_start_X - tol, paletteLength - bar_outer_offset - railThickness - tol, groove_z])
            cube([bar_length_X + 2*tol, railThickness + 2*tol, groove_depth]);
        // Left Groove
        translate([bar_outer_offset - tol, bar_start_Y - tol, groove_z])
            cube([railThickness + 2*tol, bar_length_Y + 2*tol, groove_depth]);
        // Right Groove
        translate([paletteWidth - bar_outer_offset - railThickness - tol, bar_start_Y - tol, groove_z])
            cube([railThickness + 2*tol, bar_length_Y + 2*tol, groove_depth]);

    } // End Lid Difference
}

palette_base();

translate([0, -lidPreviewGap, lidThickness]) {
    rotate([180, 0, 0]) {
        palette_lid();
    }
}
