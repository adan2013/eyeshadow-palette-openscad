// Eyeshadow Palette Generator V20

/*[Pans]*/
// Number of pans in a column
dimensionA = 3; // [1:1:6]
// Number of pans in a row
dimensionB = 2; // [1:1:6]
// pan diameter in mm
panDiameter = 26; // [20:1:40]
// depth of the pans in mm
panDepth = 3; // [3:1:6]

/*[Magnets and push holes]*/
// use pause feature to insert magnets during printing
hiddenMagnets = true;
magnetDiameter = 6; // [5:1:10]
magnetHeight = 2; // [1:1:4]
pushHoleDiameter = 3; // [3:1:6]

/*[Spacing]*/
cornerMargin = 3; // [2:1:10]
panSpacing = 6; // [3:1:10]
// extra milimeters added to the base palette thickness
extraPaletteThickness = 2; // [0:1:10]

/*[Hidden]*/
rowCount = min(dimensionA, dimensionB);
columnCount = max(dimensionA, dimensionB);

panRadius = panDiameter / 2;
magnetRadius = magnetDiameter / 2;
pushHoleRadius = pushHoleDiameter / 2;

magnetBackWallThickness = 1;
magnetFrontWallThickness = hiddenMagnets ? 1 : 0;
railHeight = 1;
railThickness = 2;
railMagnetOffset = 6 + magnetRadius;

outerMargin = magnetDiameter + cornerMargin;
magnetOffsetX = panRadius / 2;
magnetOffsetY = 0;
pushHoleOffsetX = panRadius / -2;
pushHoleOffsetY = 0;

epsilon = 0.01;
gap = 0.2;
lidPreviewGap = 5;
smoothness = 100;

lidThickness = magnetBackWallThickness + magnetHeight + magnetFrontWallThickness + 2 * gap;
paletteThickness = panDepth + magnetFrontWallThickness + magnetHeight + magnetBackWallThickness + extraPaletteThickness + 2 * gap;
paletteWidth = (columnCount * panDiameter) + ((columnCount - 1) * panSpacing) + (2 * outerMargin);
paletteLength = (rowCount * panDiameter) + ((rowCount - 1) * panSpacing) + (2 * outerMargin);

corner_magnet_center_offset = magnetRadius + cornerMargin;
bar_outer_offset = corner_magnet_center_offset - (railThickness / 2);
bar_inner_offset = bar_outer_offset + railThickness;

bar_start_Y = corner_magnet_center_offset + railMagnetOffset;
bar_end_Y   = paletteLength - corner_magnet_center_offset - railMagnetOffset;
bar_length_Y = bar_end_Y - bar_start_Y;

corner_magnet_centers = [
    [corner_magnet_center_offset, corner_magnet_center_offset], // BL
    [paletteWidth - corner_magnet_center_offset, corner_magnet_center_offset], // BR
    [corner_magnet_center_offset, paletteLength - corner_magnet_center_offset], // TL
    [paletteWidth - corner_magnet_center_offset, paletteLength - corner_magnet_center_offset] // TR
];

module palette_base() {
    union() {
        difference() {
            cube([paletteWidth, paletteLength, paletteThickness]);
            // Pans
            for (r = [0 : rowCount - 1]) {
                for (c = [0 : columnCount - 1]) {
                    x_pos = outerMargin + panRadius + c * (panDiameter + panSpacing);
                    y_pos = outerMargin + panRadius + r * (panDiameter + panSpacing);
                    // Pan hole
                    translate([x_pos, y_pos, paletteThickness - panDepth - epsilon])
                        cylinder(h = panDepth + 2 * epsilon, r = panRadius + gap, $fn = smoothness);
                    // Magnet hole
                    translate([x_pos + magnetOffsetX, y_pos + magnetOffsetY, paletteThickness - panDepth - magnetFrontWallThickness - magnetHeight - 2 * (gap + epsilon)])
                        cylinder(h = magnetHeight + 2 * (epsilon + gap), r = magnetRadius + gap, $fn = smoothness);
                    // Push hole
                    translate([x_pos + pushHoleOffsetX, y_pos + pushHoleOffsetY, -epsilon])
                        cylinder(h = paletteThickness + 2 * epsilon, r = pushHoleRadius, $fn = smoothness);
                }
            }
            // Corner magnet holes
            for (pos = corner_magnet_centers) {
                translate([pos[0], pos[1], paletteThickness - magnetFrontWallThickness - magnetHeight - epsilon - 2 * gap])
                    cylinder(h = magnetHeight + 2 * (epsilon + gap), r = magnetRadius + gap, $fn = smoothness);
            }
        }
        // Male rails
        rail_z = paletteThickness;
        translate([bar_outer_offset, bar_start_Y, rail_z])
            cube([railThickness, bar_length_Y, railHeight]); // Left rail
        translate([paletteWidth - bar_outer_offset - railThickness, bar_start_Y, rail_z])
            cube([railThickness, bar_length_Y, railHeight]); // Right rail
    }
}

module palette_lid() {
    difference() {
        cube([paletteWidth, paletteLength, lidThickness], center = false);
        // Corner magnet holes
        for (pos = corner_magnet_centers) {
            translate([pos[0], pos[1], -epsilon + magnetFrontWallThickness])
                cylinder(h = magnetHeight + 2 * (epsilon + gap), r = magnetRadius + gap, $fn = smoothness);
        }
        // Female rails
        rail_z = -epsilon;
        rail_depth = railHeight + gap + 2 * epsilon;
        translate([bar_outer_offset - gap, bar_start_Y - gap, rail_z])
            cube([railThickness + 2*gap, bar_length_Y + 2*gap, rail_depth]); // Left rail
        translate([paletteWidth - bar_outer_offset - railThickness - gap, bar_start_Y - gap, rail_z])
            cube([railThickness + 2*gap, bar_length_Y + 2*gap, rail_depth]); // Right rail
    }
}

palette_base();

translate([0, -lidPreviewGap, lidThickness]) {
    rotate([180, 0, 0]) {
        palette_lid();
    }
}
