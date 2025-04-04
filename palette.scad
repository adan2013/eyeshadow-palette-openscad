// Eyeshadow Palette Generator V20

/*[Features]*/
// add text label on lid
labelEnabled = false;
// use pause feature to insert magnets during printing
hiddenMagnets = false;
// enable bottom rails for palette stacking
stackable = false;
// remove lid from render
hideLid = false;
// remove base from render
hideBase = false;

/*[Pans]*/
// Number of pans in a column
dimensionA = 3; // [1:1:6]
// Number of pans in a row
dimensionB = 2; // [1:1:6]
// pan diameter in mm
panDiameter = 26; // [20:1:40]
// depth of the pans in mm
panDepth = 5; // [3:1:9]

/*[Magnets and push holes]*/
magnetDiameter = 6; // [5:1:10]
magnetHeight = 2; // [1:1:4]
pushHoleDiameter = 3; // [3:1:6]

/*[Spacing]*/
// outer margin behind corner magnets in mm
cornerMargin = 3; // [2:1:10]
// distance between pans in mm
panSpacing = 6; // [3:1:10]

/*[Label]*/
labelText = "My label";
labelSize = 8; // [6:1:12]
labelFont = "Arial";

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
sphereOffsetY = 17;
sphereOffsetZ = 11;
sphereRadius = 23.5;

epsilon = 0.01;
gap = 0.2;
panTolRadius = 0.5;
lidPreviewGap = 5;
labelExtrude = 0.001;
smoothness = 100;

lidThickness = magnetBackWallThickness + magnetHeight + magnetFrontWallThickness + 2 * gap;
paletteThickness = panDepth + magnetFrontWallThickness + magnetHeight + magnetBackWallThickness + 2 * gap;
paletteWidth = (columnCount * panDiameter) + ((columnCount - 1) * panSpacing) + (2 * outerMargin);
paletteLength = (rowCount * panDiameter) + ((rowCount - 1) * panSpacing) + (2 * outerMargin);

cornerMagnetCenterOffset = magnetRadius + cornerMargin;
barOuterOffset = cornerMagnetCenterOffset - (railThickness / 2);
barInnerOffset = barOuterOffset + railThickness;

barStartY = cornerMagnetCenterOffset + railMagnetOffset;
barEndY   = paletteLength - cornerMagnetCenterOffset - railMagnetOffset;
barLengthY = barEndY - barStartY;

cornerMagnetCenters = [
    [cornerMagnetCenterOffset, cornerMagnetCenterOffset], // BL
    [paletteWidth - cornerMagnetCenterOffset, cornerMagnetCenterOffset], // BR
    [cornerMagnetCenterOffset, paletteLength - cornerMagnetCenterOffset], // TL
    [paletteWidth - cornerMagnetCenterOffset, paletteLength - cornerMagnetCenterOffset] // TR
];

module roundedCube(w, l, h, r, center = false) {
    r = max(0, min(r, w/2, l/2));
    translateVector = center ? [-w/2, -l/2, -h/2] : [0, 0, 0];

    translate(translateVector) {
        linear_extrude(height = h) {
            hull() {
                translate([r, r])
                    circle(r = r, $fn = smoothness);
                translate([w - r, r])
                    circle(r = r, $fn = smoothness);
                translate([r, l - r])
                    circle(r = r, $fn = smoothness);
                translate([w - r, l - r])
                    circle(r = r, $fn = smoothness);
            }
        }
    }
}

module generateFemaleRails() {
    railZ = -epsilon;
    railDepth = railHeight + gap + epsilon;
    railWidth = railThickness + 2 * gap;
    translate([barOuterOffset - gap, barStartY - gap, railZ])
        roundedCube(railWidth, barLengthY + 2*gap, railDepth, railWidth / 2);
    translate([paletteWidth - barOuterOffset - railThickness - gap, barStartY - gap, railZ])
        roundedCube(railWidth, barLengthY + 2*gap, railDepth, railWidth / 2);
}

module generateBase() {
    union() {
        difference() {
            roundedCube(paletteWidth, paletteLength, paletteThickness, magnetRadius + cornerMargin);
            // Pans
            for (r = [0 : rowCount - 1]) {
                for (c = [0 : columnCount - 1]) {
                    xPos = outerMargin + panRadius + c * (panDiameter + panSpacing);
                    yPos = outerMargin + panRadius + r * (panDiameter + panSpacing);
                    // Pan hole
                    translate([xPos, yPos, paletteThickness - panDepth])
                        cylinder(h = panDepth + epsilon, r = panRadius + panTolRadius, $fn = smoothness);
                    // Magnet hole
                    translate([xPos + magnetOffsetX, yPos + magnetOffsetY, paletteThickness - panDepth - magnetFrontWallThickness - magnetHeight - gap])
                        cylinder(h = magnetHeight + gap + (hiddenMagnets ? 0 : epsilon), r = magnetRadius + gap/2, $fn = smoothness);
                    // Push hole
                    translate([xPos + pushHoleOffsetX, yPos + pushHoleOffsetY, -epsilon])
                        cylinder(h = paletteThickness + 2 * epsilon, r = pushHoleRadius, $fn = smoothness);
                }
            }
            // Corner magnet holes
            for (pos = cornerMagnetCenters) {
                translate([pos[0], pos[1], paletteThickness - magnetFrontWallThickness - magnetHeight -  gap])
                    cylinder(h = magnetHeight + gap + (hiddenMagnets ? 0 : epsilon), r = magnetRadius + gap/2, $fn = smoothness);
            }
            // opening handles
            translate([paletteWidth / 2, -sphereOffsetY, paletteThickness + sphereOffsetZ])
                sphere(sphereRadius, $fn=smoothness);
            translate([paletteWidth / 2, paletteLength + sphereOffsetY, paletteThickness + sphereOffsetZ])
                sphere(sphereRadius, $fn=smoothness);
            // Female stacking bottom rails
            if (stackable) generateFemaleRails();
        }
        // Male rails
        railZ = paletteThickness;
        translate([barOuterOffset, barStartY, railZ])
            roundedCube(railThickness, barLengthY, railHeight, railThickness/2);
        translate([paletteWidth - barOuterOffset - railThickness, barStartY, railZ])
            roundedCube(railThickness, barLengthY, railHeight, railThickness/2);
    }
}

module generateLid() {
    difference() {
        roundedCube(paletteWidth, paletteLength, lidThickness, magnetRadius + cornerMargin);
        // Corner magnet holes
        for (pos = cornerMagnetCenters) {
            translate([pos[0], pos[1], hiddenMagnets ? magnetFrontWallThickness : -epsilon])
                cylinder(h = magnetHeight + gap + (hiddenMagnets ? 0 : epsilon), r = magnetRadius + gap/2, $fn = smoothness);
        }
        // Female rails
        generateFemaleRails();
        // Label
        if (labelEnabled) {
            translate([paletteWidth / 2, paletteLength / 2, lidThickness - labelExtrude]) {
                linear_extrude(height = labelExtrude + epsilon) {
                    text(labelText, size = labelSize, font = labelFont, halign = "center", valign = "center");
                }
            }
        }
    }
}

if (!hideBase) {
    generateBase();
}

if (!hideLid) {
    translate([0, hideBase ? paletteLength : -lidPreviewGap, lidThickness]) {
        rotate([180, 0, 0]) {
            generateLid();
        }
    }
}