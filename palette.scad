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

panRadius = panDiameter / 2;
magnetRadius = magnetDiameter / 2;
pushHoleRadius = pushHoleDiameter / 2;

magnetHoleClearance = 1;
railHeight = 1;
railThickness = 1;
railMagnetOffset = 6 + magnetRadius;

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

corner_magnet_center_offset = magnetRadius + cornerMargin;
bar_outer_offset = corner_magnet_center_offset - (railThickness / 2);
bar_inner_offset = bar_outer_offset + railThickness;

bar_start_Y = corner_magnet_center_offset + railMagnetOffset;
bar_end_Y   = paletteLength - corner_magnet_center_offset - railMagnetOffset;
bar_length_Y = bar_end_Y - bar_start_Y;

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
                        cylinder(h = panDepth + 2 * epsilon, r = panRadius, $fn = smoothness);
                    // Magnet hole
                    translate([x_pos + magnetOffsetX, y_pos + magnetOffsetY, paletteThickness - panDepth - magnetHeight - epsilon])
                        cylinder(h = magnetHeight + 2 * epsilon, r = magnetRadius, $fn = smoothness);
                    // Push hole
                    translate([x_pos + pushHoleOffsetX, y_pos + pushHoleOffsetY, -epsilon])
                        cylinder(h = paletteThickness + 2 * epsilon, r = pushHoleRadius, $fn = smoothness);
                }
            }
            // Corner magnet holes
            corner_magnet_centers = [
                [corner_magnet_center_offset, corner_magnet_center_offset], // BL
                [paletteWidth - corner_magnet_center_offset, corner_magnet_center_offset], // BR
                [corner_magnet_center_offset, paletteLength - corner_magnet_center_offset], // TL
                [paletteWidth - corner_magnet_center_offset, paletteLength - corner_magnet_center_offset] // TR
            ];
            for (pos = corner_magnet_centers) {
                translate([pos[0], pos[1], paletteThickness - magnetHeight - epsilon])
                    cylinder(h = magnetHeight + 2 * epsilon, r = magnetRadius, $fn = smoothness);
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
        corner_magnet_centers = [
            [corner_magnet_center_offset, corner_magnet_center_offset], // BL
            [paletteWidth - corner_magnet_center_offset, corner_magnet_center_offset], // BR
            [corner_magnet_center_offset, paletteLength - corner_magnet_center_offset], // TL
            [paletteWidth - corner_magnet_center_offset, paletteLength - corner_magnet_center_offset] // TR
        ];
        for (pos = corner_magnet_centers) {
            translate([pos[0], pos[1], -epsilon])
                cylinder(h = magnetHeight + 2 * epsilon, r = magnetRadius, $fn = smoothness);
        }
        // Female rails
        rail_z = -epsilon;
        groove_depth = railHeight + gap + 2 * epsilon;
        translate([bar_outer_offset - gap, bar_start_Y - gap, rail_z])
            cube([railThickness + 2*gap, bar_length_Y + 2*gap, groove_depth]); // Left rail
        translate([paletteWidth - bar_outer_offset - railThickness - gap, bar_start_Y - gap, rail_z])
            cube([railThickness + 2*gap, bar_length_Y + 2*gap, groove_depth]); // Right rail
    }
}

palette_base();

translate([0, -lidPreviewGap, lidThickness]) {
    rotate([180, 0, 0]) {
        palette_lid();
    }
}
